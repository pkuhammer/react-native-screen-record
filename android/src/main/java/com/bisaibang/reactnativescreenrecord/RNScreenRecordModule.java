package com.bisaibang.reactnativescreenrecord;

import com.baidu.mobstat.StatService;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.ReadableMapKeySetIterator;

import java.util.HashMap;

/**
 * Created by yangjie18 on 17/8/17.
 */

public class RNScreenRecordModule extends ReactContextBaseJavaModule {

    private ReactApplicationContext reactContext;

    public RNScreenRecordModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
    }

    @Override
    public String getName() {
        return "ScreenRecord";
    }

}
