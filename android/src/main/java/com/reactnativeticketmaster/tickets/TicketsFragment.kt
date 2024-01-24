package com.reactnativeticketmaster.tickets

import android.content.Context
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.compose.material.darkColors
import androidx.compose.material.lightColors
import androidx.compose.ui.graphics.Color
import androidx.fragment.app.Fragment
import com.reactnativeticketmaster.BuildConfig
import com.reactnativeticketmaster.R
import com.ticketmaster.authenticationsdk.AuthSource
import com.ticketmaster.authenticationsdk.TMAuthentication
import com.ticketmaster.authenticationsdk.TMXDeploymentEnvironment
import com.ticketmaster.authenticationsdk.TMXDeploymentRegion
import com.ticketmaster.tickets.ticketssdk.TicketsColors
import com.ticketmaster.tickets.ticketssdk.TicketsSDKClient
import com.ticketmaster.tickets.ticketssdk.TicketsSDKSingleton
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class TicketsFragment() : Fragment() {
    private lateinit var customView: TicketsView

    private fun createTicketsColors(color: Int): TicketsColors =
        TicketsColors(
            lightColors(primary = Color(color), primaryVariant = Color(color), secondary = Color(color)),
            darkColors(primary = Color(color), primaryVariant = Color(color), secondary = Color(color))
        )

    private suspend fun validateAuthToken(authentication: TMAuthentication): Map<AuthSource, String> {
        val tokenMap = mutableMapOf<AuthSource, String>()
        AuthSource.values().forEach {
            //Validate if there is an active token for the AuthSource, if not it returns null.
            authentication.getToken(it)?.let { token ->
                tokenMap[it] = token
            }
        }
        return tokenMap
    }

    private fun launchTicketsView() {
        //Retrieve an EventFragment
        TicketsSDKSingleton.getEventsFragment(requireContext())?.let {
            childFragmentManager.beginTransaction().add(R.id.container, it).commit()
        }
    }

    private val resultLauncher = registerForActivityResult(
        ActivityResultContracts.StartActivityForResult()
    ) { result ->
        when (result.resultCode) {
            AppCompatActivity.RESULT_OK -> launchTicketsView()
            AppCompatActivity.RESULT_CANCELED -> {
            }
        }
    }

    override fun onAttach(context: Context) {
        super.onAttach(context)
        val coroutineScope = CoroutineScope(Dispatchers.IO)
        coroutineScope.launch(Dispatchers.Main) {
            val authentication = TMAuthentication.Builder()
                .apiKey(Config.get("apiKey"))
                .clientName(Config.get("clientName")) // Team name to be displayed
                .colors(TMAuthentication.ColorTheme())
                .environment(TMXDeploymentEnvironment.Production) // Environment that the SDK will use. Default is Production
                .region(TMXDeploymentRegion.US) // Region that the SDK will use. Default is US
                .build(this@TicketsFragment.requireActivity())
            val tokenMap = validateAuthToken(authentication)

            TicketsSDKClient
                .Builder()
                .authenticationSDKClient(authentication) //Authentication object
                //Optional value to define the colors for the Tickets page
                .colors(createTicketsColors(android.graphics.Color.parseColor("#231F20")))
                //Function that generates a TicketsSDKClient object
                .build(this@TicketsFragment.requireActivity())
                .apply {
                    //After creating the TicketsSDKClient object, add it into the TicketsSDKSingleton
                    TicketsSDKSingleton.setTicketsSdkClient(this)

                    //Validate if there is an active token.
                    if (tokenMap.isNotEmpty()) {
                        //If there is an active token, it launches the event fragment
                        launchTicketsView()
                    } else {
                        //If there is no active token, it launches a login intent. Launch an ActivityForResult, if result
                        //is RESULT_OK, there is an active token to be retrieved.
                        resultLauncher.launch(TicketsSDKSingleton.getLoginIntent(this@TicketsFragment.requireActivity()))
                    }
                }
        }
    }

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        customView = TicketsView(requireNotNull(context))
        return customView // this CustomView could be any view that you want to render

    }
}