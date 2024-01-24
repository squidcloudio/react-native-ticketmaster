import React, { createContext, useEffect, useState } from 'react';
import { NativeEventEmitter, NativeModules, Platform } from 'react-native';

export type TicketmasterContextType = {
  login: () => Promise<void>;
  logout: () => Promise<void>;
  memberInfo: Record<string, any> | null;
  isLoggedIn: boolean;
  getToken: () => Promise<string | null>;
  refreshToken: () => Promise<string | null>;
};

type ChangeEvent =
  | 'serviceConfigurationStarted'
  | 'serviceConfigured'
  | 'serviceConfigurationCompleted'
  | 'loginStarted'
  | 'loginPresented'
  | 'loggedIn'
  | 'loginAborted'
  | 'loginFailed'
  | 'loginLinkAccountPresented'
  | 'loginCompleted'
  | 'tokenRefreshed'
  | 'logoutStarted'
  | 'loggedOut'
  | 'logoutCompleted';

export const TicketmasterContext = createContext<TicketmasterContextType>({
  login: async () => {},
  logout: async () => {},
  isLoggedIn: false,
  memberInfo: null,
  getToken: async () => null,
  refreshToken: async () => null,
});

export const TicketmasterProvider = ({
  children,
  options,
}: {
  children: React.ReactNode;
  options: { apiKey: string; clientName: string };
}) => {
  const { Config, AccountsSDK } = NativeModules;

  const { apiKey, clientName } = options;
  Config.setConfig('apiKey', apiKey);
  Config.setConfig('clientName', clientName);

  const refresh = (platform?: 'ios' | 'android') => {
    if (!platform || Platform.OS === platform) {
      console.log('refreshing...');
      getIsLoggedIn().then(setisLoggedIn);
      getMemberInfo().then(setMemberInfo);
    }
  };

  useEffect(() => {
    const configure = async () => {
      try {
        const result = await AccountsSDK.configureAccountsSDK();
        console.log('Configuration set:', result);
      } catch (e: any) {
        console.error('Accounts SDK Configuration error:', e.message);
      } finally {
        refresh('android');
      }
    };
    configure().then();
  }, []);

  useEffect(() => {
    if (Platform.OS !== 'ios') {
      return;
    }

    const events = new NativeEventEmitter(AccountsSDK);

    const subscription = events.addListener(
      'onStateChanged',
      (event: ChangeEvent) => {
        switch (event) {
          case 'loginCompleted':
          case 'loginFailed':
          case 'loginAborted':
          case 'logoutCompleted':
          case 'serviceConfigurationCompleted':
          case 'tokenRefreshed':
            refresh();
            break;
          default:
            break;
        }
      },
    );

    return () => {
      subscription.remove();
    };
  }, []);

  const login = async (): Promise<void> => {
    return new Promise(async (resolve, reject) => {
      if (Platform.OS === 'android') {
        AccountsSDK.login((resultCode: any) => {
          console.log('Login result code: ', resultCode);
          refresh('android');
          resolve();
        });
      } else if (Platform.OS === 'ios') {
        try {
          const result = await AccountsSDK.login();
          console.log('Accounts SDK Login access token:', result);
          resolve();
        } catch (err) {
          reject(err);
        }
      }
    });
  };

  const logout = async () => {
    try {
      await AccountsSDK.logout();
    } catch (e) {
      throw e;
    } finally {
      refresh('android');
    }
  };

  const getIsLoggedIn = async (): Promise<boolean> => {
    let result;
    try {
      if (Platform.OS === 'android') {
        result = await AccountsSDK.isLoggedIn();
      } else if (Platform.OS === 'ios') {
        const isLoggedIn = await AccountsSDK.isLoggedIn();
        result = isLoggedIn.result;
      }
      console.log('Is logged in: ', result);
      return result;
    } catch (e: any) {
      if (e.message.includes('User not logged in')) {
        return false;
      } else {
        throw e;
      }
    }
  };

  const getMemberInfo = async (): Promise<Record<string, any> | null> => {
    let result;
    try {
      result = await AccountsSDK.getMemberInfo();
      return result;
    } catch (e: any) {
      if (e.message.includes('User not logged in')) {
        return null;
      } else {
        throw e;
      }
    }
  };

  const refreshToken = async (): Promise<string> => {
    try {
      const result = await AccountsSDK.refreshToken();
      console.log('Refresh access token:', result);
      return result;
    } catch (e) {
      throw e;
    } finally {
      refresh('android');
    }
  };

  const getToken = async (): Promise<string | null> => {
    let result;

    try {
      if (Platform.OS === 'android') {
        result = await AccountsSDK.refreshToken();
      } else if (Platform.OS === 'ios') {
        // iOS getToken has the exact same Native logic as refreshToken, but will not display the login UI if a user is not logged in
        result = await AccountsSDK.getToken();
      }
      console.log('Get access token:', result);
      return result;
    } catch (e: any) {
      if (e.message.includes('User not logged in')) {
        return null;
      } else {
        throw e;
      }
    } finally {
      refresh('android');
    }
  };

  const [isLoggedIn, setisLoggedIn] = useState<boolean>(false);
  const [memberInfo, setMemberInfo] = useState<Record<string, any> | null>(
    null,
  );

  return (
    <TicketmasterContext.Provider
      value={{ login, logout, refreshToken, getToken, isLoggedIn, memberInfo }}
    >
      {children}
    </TicketmasterContext.Provider>
  );
};
