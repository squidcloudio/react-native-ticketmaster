package com.reactnativeticketmaster.retail

import android.content.Context
import android.widget.FrameLayout
import com.reactnativeticketmaster.R

class PurchaseView(context: Context) : FrameLayout(context) {
    init {
        FrameLayout(context)
        addView(FrameLayout(context).apply { id = R.id.purchase_container })
    }
}
