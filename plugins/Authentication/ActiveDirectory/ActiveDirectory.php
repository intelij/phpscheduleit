<?php
/**
Copyright 2011-2012 Nick Korbel

This file is part of phpScheduleIt.

phpScheduleIt is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

phpScheduleIt is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with phpScheduleIt.  If not, see <http://www.gnu.org/licenses/>.
*/

require_once(ROOT_DIR . 'lib/Application/Authentication/namespace.php');
require_once(ROOT_DIR . 'plugins/Authentication/ActiveDirectory/namespace.php');

/**
 * Provides ActiveDirectory LDAP authentication/synchronization for phpScheduleIt
 * @see IAuthorization
 */
class ActiveDirectory extends Authentication implements IAuthentication
{
	/**
	 * @var IAuthentication
	 */
	private $authToDecorate;

	/**
	 * @var AdLdapWrapper
	 */
	private $ldap;

	/**
	 * @var ActiveDirectoryOptions
	 */
	private $options;

	/**
	 * @var IRegistration
	 */
	private $_registration;

	/**
	 * @var PasswordEncryption
	 */
	private $_encryption;

	/**
	 * @var ActiveDirectoryUser
	 */
	private $user = null;

	/**
	 * @var string
	 */
	private $password;

	public function SetRegistration($registration)
	{
		$this->_registration = $registration;
	}

	private function GetRegistration()
	{
		if ($this->_registration == null)
		{
			$this->_registration = new Registration();
		}

		return $this->_registration;
	}

	public function SetEncryption($passwordEncryption)
	{
		$this->_encryption = $passwordEncryption;
	}

	private function GetEncryption()
	{
		if ($this->_encryption == null)
		{
			$this->_encryption = new PasswordEncryption();
		}

		return $this->_encryption;
	}


	/**
	 * @param IAuthentication $authentication Authentication class to decorate
	 * @param IActiveDirectory $ldapImplementation The actual LDAP implementation to work against
	 * @param ActiveDirectoryOptions $ldapOptions Options to use for LDAP configuration
	 */
	public function __construct(IAuthentication $authentication, $ldapImplementation = null, $ldapOptions = null)
	{
		$this->authToDecorate = $authentication;

		$this->options = $ldapOptions;
		if ($ldapOptions == null)
		{
			$this->options = new ActiveDirectoryOptions();
		}

		$this->ldap = $ldapImplementation;
		if ($ldapImplementation == null)
		{
			$this->ldap = new AdLdapWrapper($this->options);
		}
	}

	public function Validate($username, $password)
	{
		$this->password = $password;

		$username = $this->CleanUsername($username);
		$connected = $this->ldap->Connect();

        if (!$connected)
        {
            throw new Exception('Could not connect to ActiveDirectory LDAP server. Please check your ActiveDirectory LDAP configuration settings');
        }

        $isValid = $this->ldap->Authenticate($username, $password);
        Log::Debug('Result of ActiveDirectory LDAP Authenticate for user %s: %d', $username, $isValid);

        if ($isValid)
        {
            $this->user = $this->ldap->GetLdapUser($username);
            $userLoaded = $this->LdapUserExists();

            if (!$userLoaded)
            {
                Log::Error('Could not load user details from ActiveDirectory LDAP. Check your basedn setting. User: %s', $username);
            }
            return $userLoaded;
        }
        else
        {
            if ($this->options->RetryAgainstDatabase())
            {
                return $this->authToDecorate->Validate($username, $password);
            }
        }

		return false;
	}

	public function Login($username, $loginContext)
	{
		$username = $this->CleanUsername($username);
		Log::Debug('ActiveDirectory - Login() in with username: %s', $username);
		if ($this->LdapUserExists())
		{
			Log::Debug('Running ActiveDirectory user synchronization for username: %s, Attributes: %s', $username, $this->user->__toString());
			$this->Synchronize($username);
		}
		else
		{
			Log::Debug('Skipping ActiveDirectory user synchronization, user not loaded');
		}

		$this->authToDecorate->Login($username, $loginContext);
	}

	public function Logout(UserSession $user)
	{
		$this->authToDecorate->Logout($user);
	}

	public function CookieLogin($cookieValue, $loginContext)
	{
		$this->authToDecorate->CookieLogin($cookieValue, $loginContext);
	}

	public function AreCredentialsKnown()
	{
		return false;
	}

	public function HandleLoginFailure(ILoginPage $loginPage)
	{
		$this->authToDecorate->HandleLoginFailure($loginPage);
	}

	private function LdapUserExists()
	{
		return $this->user != null;
	}

	private function Synchronize($username)
	{
		$registration = $this->GetRegistration();

		$registration->Synchronize(
			new AuthenticatedUser(
                $username,
                $this->user->GetEmail(),
                $this->user->GetFirstName(),
                $this->user->GetLastName(),
                $this->password,
                Configuration::Instance()->GetKey(ConfigKeys::LANGUAGE),
				Configuration::Instance()->GetKey(ConfigKeys::SERVER_TIMEZONE),
				$this->user->GetPhone(), $this->user->GetInstitution(),
                $this->user->GetTitle())
		);
	}

	private function CleanUsername($username)
	{
		if (StringHelper::Contains($username, '@'))
		{
			Log::Debug('ActiveDirectory - Username %s appears to be an email address. Cleaning...', $username);
			$parts = explode('@', $username);
			$username = $parts[0];
		}
		if (StringHelper::Contains($username, '\\'))
		{
			Log::Debug('ActiveDirectory - Username %s appears contain a domain. Cleaning...', $username);
			$parts = explode('\\', $username);
			$username = $parts[1];
		}

		return $username;
	}
}

?>