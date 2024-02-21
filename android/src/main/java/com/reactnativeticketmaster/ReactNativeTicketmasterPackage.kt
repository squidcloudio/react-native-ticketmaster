package com.reactnativeticketmaster

import com.facebook.react.ReactPackage
import com.facebook.react.bridge.NativeModule
import com.facebook.react.bridge.ReactApplicationContext
import com.reactnativeticketmaster.tickets.TicketsViewManager

public class ReactNativeTicketmasterPackage : ReactPackage {
    override fun createViewManagers(
        reactContext: ReactApplicationContext
    ) = listOf(TicketsViewManager(reactContext))

    override fun createNativeModules(
        reactContext: ReactApplicationContext
    ): MutableList<NativeModule> = listOf(AccountsSDKModule(reactContext), ConfigModule(reactContext)).toMutableList()
}