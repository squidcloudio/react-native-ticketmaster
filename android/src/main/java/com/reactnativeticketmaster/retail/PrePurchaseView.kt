package com.reactnativeticketmaster.retail

import android.content.Context
import android.widget.FrameLayout
import com.reactnativeticketmaster.R

class PrePurchaseView(context: Context) : FrameLayout(context){
    init {
        FrameLayout(context)
        addView(FrameLayout(context)).apply { id = R.id.venue_container }
    }
}
