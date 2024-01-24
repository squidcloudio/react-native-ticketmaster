package com.reactnativeticketmaster.tickets

import android.content.Context
import android.widget.FrameLayout
import com.reactnativeticketmaster.R

class TicketsView(context: Context) : FrameLayout(context) {
    init {
        FrameLayout(context)
        addView(FrameLayout(context).apply { id = R.id.container })
    }
}
