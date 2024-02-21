# react-native-ticketmaster

React Native wrapper for the [Ticketmaster Ignite SDK](https://ignite.ticketmaster.com/docs), inspired by Ticketmaster's React Native [demo integration](https://github.com/ticketmaster/ReactNative-TicketmasterDemoIntegration). This module can be added to a React Native project without needing to write any native code.

## Getting started

Install the library:

```bash
npm install @squidcloud/react-native-ticketmaster
```

### Using React Native

#### iOS

Beyond `pod install`, there's no configuration necessary!

#### Android

Modify your **android/app/build.gradle** configuration:

```
android {
  ...
  buildFeatures {
    dataBinding = true
  }
}
```

Modify your **android/build.gradle** configuration:

```
allprojects {
    repositories {
        ...
        jcenter()
    }
}
```

### Using Expo

This package _almost_ works with the Expo managed workflow, but not quite. Currently, there are two issues on Android that prevent using with module with a generated `android` project.

1. The underlying Ticketmaster SDKs use `jcenter()`, which is not included by default in the generated `android/build.gradle`.
2. The underlying Ticketmaster SDKs require the `dataBinding` feature, which must be added to the `android/app/build.gradle`.

There is an [open issue](https://github.com/ticketmaster/ReactNative-TicketmasterDemoIntegration/issues/8) with Ticketmaster tracking ways to improve the SDK so that it can be used with the Expo managed workflow.

If you're using the Expo bare workflow, simply follow the React Native steps above.

## Usage

### TicketmasterProvider

The `TicketmasterProvider` wraps your app with a context that enables all other Ticketmaster actions.

```tsx
// in your entry file like `App.js`
import { TicketmasterProvider } from "@squidcloud/react-native-ticketmaster";

// in your render function
return (
  <TicketmasterProvider
    options={{
      apiKey: "API_KEY",
      clientName: "CLIENT_NAME",
    }}
  >
    <App />
  </TicketmasterProvider>
);
```

Here you must pass your Ticketmaster API Key, as well as the name of the client (which will be displayed on the Ticketmaster "Sign In" screen).

### useTicketmaster

The `useTicketmaster` hooks exposes the following:

- `isLoggedIn: boolean` - Whether a user is currently authenticated with the Ticketmaster SDK.
- `memberInfo: Object` - The information about that member, such as email and member ID.
- `login: () => Promise<void>` - Prompts the user to log in to Ticketmaster, unless they're already logged in.
- `logout: () => Promise<void>` - Logs the user out of Ticketmaster, unless they're already logged out.
- `getToken: () => Promise<string | null>` - Returns the current access token of a logged-in user, or null.
- `refreshToken: () => Promise<string | null>` - Refreshed the token for a logged-in user. Returns the new token, or null.

```tsx
import { useTicketmaster } from "@squidcloud/react-native-ticketmaster";

const { isLoggedIn, memberInfo, login, logout, getToken, refreshToken } =
  useTicketmaster();
```

### Components

#### TicketsSDK

This component uses the Ticketmaster [Tickets SDK](https://ignite.ticketmaster.com/docs/tickets-sdk-overview) to show the user's tickets (or the Sign In screen if the user is not authenticated).

Due to how the native SDKs work, the component has slightly different behavior on Android and iOS.

##### Android

The component is rendered as an embedded view, and can be rendered directly.

```tsx
import { TicketsSdk } from "@squidcloud/react-native-ticketmaster";

// in your render function
return (
  <View style={{ flex: 1 }}>
    <TicketsSdk />
  </View>
);
```

##### iOS

On iOS rendering the component will trigger a modal that shows the tickets (or "Sign In" screen). In this case, it's recommended to attach the rendering of the component to a user action:

```tsx
import { TicketsSdk } from "@squidcloud/react-native-ticketmaster";

const MyPage = () => {
  const [showModal, setShowModal] = useState(false);

  const onPress = () => {
    // On iOS, the Tickets view is a native modal, so we show it and then reset the state.
    // This ensures that pressing the button will display the modal again after it's been
    // dismissed.
    setShowModal(true);
    setTimeout(() => {
      setShowModal(false);
    }, 500);
  };

  return (
    <>
      <TouchableOpacity onPress={onPress}>
        <Text>Tickets</Text>
      </TouchableOpacity>
      {showModal && (
        <View>
          <TicketsSdk />
        </View>
      )}
    </>
  );
};
```

#### PurchaseSdk

This component uses the Ticketmaster Retail SDK to start a [purchase](https://ignite.ticketmaster.com/docs/purchase-overview) flow. Similar to the `TicketSdk` above, the behavior of the component varies between iOS and Android.

##### Android

On Android, the `presentPurchase` function can be used to start the Purchase activity. The function takes an `eventId` as a prop.

```tsx
import { useTicketmaster } from "@squidcloud/react-native-ticketmaster";

const MyPage = () => {
  const { presentPurchase } = useTicketmaster();

  return <Button onPress={() => presentPurchase(eventId)} title="Purchase" />;
};
```

##### iOS

On iOS, Follow the guidance from the `TicketsSdk` to properly render the component, with one exception - the component takes an `eventId` as a prop.

```tsx
import { PurchaseSdk } from "@squidcloud/react-native-ticketmaster";

return <PurchaseSdk eventId={eventId} />;
```

#### PrePurchaseSdk

This component uses the Ticketmaster Retail SDK to start a [prepurchase](https://ignite.ticketmaster.com/docs/pre-purchase-overview) flow. Similar to the `TicketSdk` and `PurchaseSdk` above, the behavior of the component varies between iOS and Android.

##### Android

On Android, the `presentPrePurchase` function can be used to start the PrePurchase activity. The function takes an `attractionId` as a prop.

```tsx
import { useTicketmaster } from "@squidcloud/react-native-ticketmaster";

const MyPage = () => {
  const { presentPrePurchase } = useTicketmaster();

  return (
    <Button
      onPress={() => presentPrePurchase(attractionId)}
      title="PrePurchase"
    />
  );
};
```

##### iOS

On iOS, follow the guidance from the `TicketsSdk` to properly render the component, with one exception - the component takes an `attractionId` as a prop.

```tsx
import { PrePurchaseSdk } from "@squidcloud/react-native-ticketmaster";

return <PrePurchaseSdk attractionId={attractionId} />;
```
