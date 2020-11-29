package io.idhea.flutterzoop;

import android.app.Activity;
import android.Manifest;
import android.annotation.TargetApi;
import android.app.Application;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothGatt;
import android.bluetooth.BluetoothGattCallback;
import android.bluetooth.BluetoothGattCharacteristic;
import android.bluetooth.BluetoothGattDescriptor;
import android.bluetooth.BluetoothGattServer;
import android.bluetooth.BluetoothGattService;
import android.bluetooth.BluetoothManager;
import android.bluetooth.BluetoothProfile;
import android.bluetooth.le.BluetoothLeScanner;
import android.bluetooth.le.ScanCallback;
import android.bluetooth.le.ScanFilter;
import android.bluetooth.le.ScanResult;
import android.bluetooth.le.ScanSettings;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.ParcelUuid;
import android.util.Log;

import com.google.protobuf.ByteString;
import com.google.protobuf.InvalidProtocolBufferException;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.Vector;

import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.common.PluginRegistry.RequestPermissionsResultListener;

import com.zoop.zoopandroidsdk.TerminalListManager;
import com.zoop.zoopandroidsdk.ZoopAPI;
import com.zoop.zoopandroidsdk.ZoopTerminalPayment;
import com.zoop.zoopandroidsdk.commons.Extras;
import com.zoop.zoopandroidsdk.terminal.ApplicationDisplayListener;
import com.zoop.zoopandroidsdk.terminal.DeviceSelectionListener;
import com.zoop.zoopandroidsdk.terminal.ExtraCardInformationListener;
import com.zoop.zoopandroidsdk.terminal.TerminalMessageType;
import com.zoop.zoopandroidsdk.terminal.TerminalPaymentListener;

import org.json.JSONException;
import org.json.JSONObject;

/** FlutterzoopPlugin */
public class FlutterzoopPlugin implements FlutterPlugin, ActivityAware, MethodCallHandler,
    RequestPermissionsResultListener, EventChannel.StreamHandler {
  private static final String TAG = "FlutterzoopPlugin";
  private static FlutterzoopPlugin instance;
  private Object initializationLock = new Object();
  private Context context;
  private MethodChannel channel;
  private static final String NAMESPACE = "io.idhea.flutterzoop/flutter_zoop";

  private EventChannel stateChannel;
  private BluetoothManager mBluetoothManager;
  private BluetoothAdapter mBluetoothAdapter;

  private FlutterPluginBinding pluginBinding;
  private ActivityPluginBinding activityBinding;
  private Application application;
  private Activity activity;

  private static final int REQUEST_FINE_LOCATION_PERMISSIONS = 1452;

  // Pending call and result for startScan, in the case where permissions are
  // needed
  private MethodCall pendingCall;
  private Result pendingResult;
  private ArrayList<String> macDeviceScanned = new ArrayList<>();
  private boolean allowDuplicates = false;

  // zoop vars
  private ZoopAPI zoopAPI;
  private DeviceSelectionListener deviceSelectionListener;
  private TerminalListManager terminalListManager;

  private TerminalPaymentListener terminalPaymentListener;
  private ZoopTerminalPayment zoopTerminalPayment;
  private ApplicationDisplayListener applicationDisplayListener;
  private ExtraCardInformationListener extraCardInformationListener;

  private String lastId = "";

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    if (instance == null) {
      instance = new FlutterzoopPlugin();
    }
    Activity activity = registrar.activity();
    Application application = null;
    if (registrar.context() != null) {
      application = (Application) (registrar.context().getApplicationContext());
    }
    instance.setup(registrar.messenger(), application, activity, registrar, null);
  }

  public FlutterzoopPlugin() {
  }

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    pluginBinding = binding;
  }

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) {
    pluginBinding = null;
  }

  @Override
  public void onAttachedToActivity(ActivityPluginBinding binding) {
    activityBinding = binding;
    setup(pluginBinding.getBinaryMessenger(), (Application) pluginBinding.getApplicationContext(),
        activityBinding.getActivity(), null, activityBinding);
  }

  @Override
  public void onDetachedFromActivity() {
    tearDown();
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity();
  }

  @Override
  public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {
    onAttachedToActivity(binding);
  }

  private void setup(final BinaryMessenger messenger, final Application application, final Activity activity,
      final PluginRegistry.Registrar registrar, final ActivityPluginBinding activityBinding) {
    synchronized (initializationLock) {
      Log.i(TAG, "setup");
      this.activity = activity;
      this.application = application;
      channel = new MethodChannel(messenger, NAMESPACE + "/methods");
      channel.setMethodCallHandler(this);
      stateChannel = new EventChannel(messenger, NAMESPACE + "/state");
      stateChannel.setStreamHandler(stateHandler);
      mBluetoothManager = (BluetoothManager) application.getSystemService(Context.BLUETOOTH_SERVICE);
      mBluetoothAdapter = mBluetoothManager.getAdapter();
      if (registrar != null) {
        // V1 embedding setup for activity listeners.
        registrar.addRequestPermissionsResultListener(this);
      } else {
        // V2 embedding setup for activity listeners.
        activityBinding.addRequestPermissionsResultListener(this);
      }

      if (zoopAPI == null) {
        try {
          zoopAPI.initialize(this.application.getApplicationContext());
          deviceSelectionListener = new DeviceSelectionListener() {
            @Override
            public void showDeviceListForUserSelection(Vector<JSONObject> vector) {
              invokeMethodUIThread("Devices", vector.toString());
            }

            @Override
            public void updateDeviceListForUserSelection(JSONObject jsonObject, Vector<JSONObject> vector, int i) {
              invokeMethodUIThread("Devices", vector.toString());
            }

            @Override
            public void bluetoothIsNotEnabledNotification() {
              System.out.println("BLUETOOTH DESATIVADO");
            }

            @Override
            public void deviceSelectedResult(JSONObject jsonObject, Vector<JSONObject> vector, int i) {
              System.out.println("deviceSelectedResult" + jsonObject);
            }
          };

          terminalListManager = new TerminalListManager(deviceSelectionListener,
              this.application.getApplicationContext());

          terminalPaymentListener = new TerminalPaymentListener() {
            @Override
            public void paymentFailed(JSONObject jsonObject) {
              invokeMethodUIThread("PaymentFailed", jsonObject.toString());
            }

            @Override
            public void paymentDuplicated(JSONObject jsonObject) {
              System.out.println("paymentDuplicated" + jsonObject);

            }

            @Override
            public void paymentSuccessful(JSONObject jsonObject) {
              try {
                if (lastId != jsonObject.get("id")) {
                  invokeMethodUIThread("PaymentSuccessful", jsonObject.toString());
                  lastId = (String) jsonObject.get("id");
                }
              } catch (JSONException e) {
                e.printStackTrace();
              }
            }

            @Override
            public void paymentAborted() {
              invokeMethodUIThread("PaymentAborted", "paymentAbort");
            }

            @Override
            public void cardholderSignatureRequested() {
              System.out.println("cardholderSignatureRequested");
            }

            @Override
            public void currentChargeCanBeAbortedByUser(boolean b) {
              System.out.println("currentChargeCanBeAbortedByUser" + b);

            }

            @Override
            public void signatureResult(int i) {
              System.out.println("signatureResult" + i);
            }
          };

          applicationDisplayListener = new ApplicationDisplayListener() {
            @Override
            public void showMessage(String s, TerminalMessageType terminalMessageType) {
              JSONObject json = new JSONObject();
              try {
                json.put("message", s);
                json.put("terminalMessageType", terminalMessageType.toString());
              } catch (JSONException e) {
                e.printStackTrace();
              }
              invokeMethodUIThread("TerminalMessage", json.toString());
            }

            @Override
            public void showMessage(String s, TerminalMessageType terminalMessageType, String s1) {
              System.out.println("applicationDisplayListener showMessage 2" + s);
            }
          };

          extraCardInformationListener = new ExtraCardInformationListener() {
            @Override
            public void cardLast4DigitsRequested() {
              System.out.println("cardLast4DigitsRequested ");
            }

            @Override
            public void cardExpirationDateRequested() {
              System.out.println("cardExpirationDateRequested ");
            }

            @Override
            public void cardCVCRequested() {
              System.out.println("cardCVCRequested ");
            }
          };

          try {
            zoopTerminalPayment = new ZoopTerminalPayment();
            zoopTerminalPayment.setTerminalPaymentListener(terminalPaymentListener);
            zoopTerminalPayment.setApplicationDisplayListener(applicationDisplayListener);
            zoopTerminalPayment.setExtraCardInformationListener(extraCardInformationListener);
          } catch (Exception err) {
            System.out.println("zoopTerminalPayment exception - " + err.toString());
          }

        } catch (Exception e) {
          e.printStackTrace();
        }
      }
    }
  }

  private void requestZoopDeviceSelection(JSONObject jsonObject) {
    terminalListManager.requestZoopDeviceSelection(jsonObject);
  }

  private void charge(JSONObject jsonObject) {
    try {
      BigDecimal valueToCharge = BigDecimal.valueOf((double) jsonObject.get("valueToCharge"));
      int paymentOption = (int) jsonObject.get("paymentOption");
      int numberInstall = (int) jsonObject.get("iNumberOfInstallments");
      String marketplaceId = (String) jsonObject.get("marketplaceId");
      String sellerId = (String) jsonObject.get("sellerId");
      String publishableKey = (String) jsonObject.get("publishableKey");

      zoopTerminalPayment.charge(valueToCharge, paymentOption, numberInstall, marketplaceId, sellerId, publishableKey);

    } catch (JSONException e) {
      e.printStackTrace();
    } catch (Exception e) {
      e.printStackTrace();
    }
  }

  private void abortCharge(Result result) {
    try {
      zoopTerminalPayment.requestAbortCharge();
    } catch (Exception e) {
      e.printStackTrace();
    }
  }

  private void tearDown() {
    Log.i(TAG, "teardown");
    context = null;
    activityBinding.removeRequestPermissionsResultListener(this);
    activityBinding = null;
    channel.setMethodCallHandler(null);
    channel = null;
    stateChannel.setStreamHandler(null);
    stateChannel = null;
    mBluetoothAdapter = null;
    mBluetoothManager = null;
    application = null;
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (mBluetoothAdapter == null && !"isAvailable".equals(call.method)) {
      result.error("bluetooth_unavailable", "the device does not have bluetooth", null);
      return;
    }

    switch (call.method) {
      case "state": {
        Protos.BluetoothState.Builder p = Protos.BluetoothState.newBuilder();
        try {
          switch (mBluetoothAdapter.getState()) {
            case BluetoothAdapter.STATE_OFF:
              p.setState(Protos.BluetoothState.State.OFF);
              break;
            case BluetoothAdapter.STATE_ON:
              p.setState(Protos.BluetoothState.State.ON);
              break;
            case BluetoothAdapter.STATE_TURNING_OFF:
              p.setState(Protos.BluetoothState.State.TURNING_OFF);
              break;
            case BluetoothAdapter.STATE_TURNING_ON:
              p.setState(Protos.BluetoothState.State.TURNING_ON);
              break;
            default:
              p.setState(Protos.BluetoothState.State.UNKNOWN);
              break;
          }
        } catch (SecurityException e) {
          p.setState(Protos.BluetoothState.State.UNAUTHORIZED);
        }
        result.success(p.build().toByteArray());
        break;
      }

      case "isAvailable": {
        result.success(mBluetoothAdapter != null);
        break;
      }

      case "isOn": {
        result.success(mBluetoothAdapter.isEnabled());
        break;
      }

      case "requestConnection": {
        String data = call.arguments();
        try {          
          JSONObject obj = new JSONObject(data);
          requestZoopDeviceSelection(obj);
          result.success(true);
        } catch (JSONException e) {
          e.printStackTrace();
        }
        break;
      }

      case "charge": {
        String data = call.arguments();
        try {
          JSONObject obj = new JSONObject(data);
          charge(obj);
          result.success(true);
        } catch (JSONException e) {
          e.printStackTrace();
        }
        break;
      }

      case "abortCharge": {
        abortCharge(result);
        result.success(true);
      }

      case "startScan": {
        if (ContextCompat.checkSelfPermission(activity,
            Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
          ActivityCompat.requestPermissions(activity, new String[] { Manifest.permission.ACCESS_FINE_LOCATION },
              REQUEST_FINE_LOCATION_PERMISSIONS);
          pendingCall = call;
          pendingResult = result;
          break;
        }
        startScan(call, result);
        break;
      }

      case "stopScan": {
        terminalListManager.finishTerminalDiscovery();
        result.success(null);
        break;
      }

      case "getConnectedDevices": {
        List<BluetoothDevice> devices = mBluetoothManager.getConnectedDevices(BluetoothProfile.GATT);
        Protos.ConnectedDevicesResponse.Builder p = Protos.ConnectedDevicesResponse.newBuilder();
        for (BluetoothDevice d : devices) {
          p.addDevices(ProtoMaker.from(d));
        }
        result.success(p.build().toByteArray());
        // log(LogLevel.EMERGENCY, "mDevices size: " + mDevices.size());
        break;
      }
      case "deviceState": {
        String deviceId = (String) call.arguments;
        BluetoothDevice device = mBluetoothAdapter.getRemoteDevice(deviceId);
        int state = mBluetoothManager.getConnectionState(device, BluetoothProfile.GATT);
        try {
          result.success(ProtoMaker.from(device, state).toByteArray());
        } catch (Exception e) {
          result.error("device_state_error", e.getMessage(), e);
        }
        break;
      }

      default: {
        result.notImplemented();
        break;
      }
    }
  }

  @Override
  public boolean onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
    if (requestCode == REQUEST_FINE_LOCATION_PERMISSIONS) {
      if (grantResults[0] == PackageManager.PERMISSION_GRANTED) {        
        try {
          startScan(pendingCall, pendingResult);
        } catch (Exception e) {
            Log.d(TAG, "onRequestPermissionsResult error " + e.getMessage());  
        }
      } else {
        pendingResult.error("no_permissions", "flutter_blue plugin requires location permissions for scanning", null);
        pendingResult = null;
        pendingCall = null;
      }
      return true;
    }
    return false;
  }

  private final StreamHandler stateHandler = new StreamHandler() {
    private EventSink sink;

    private final BroadcastReceiver mReceiver = new BroadcastReceiver() {
      @Override
      public void onReceive(Context context, Intent intent) {
        final String action = intent.getAction();

        if (BluetoothAdapter.ACTION_STATE_CHANGED.equals(action)) {
          final int state = intent.getIntExtra(BluetoothAdapter.EXTRA_STATE, BluetoothAdapter.ERROR);
          switch (state) {
            case BluetoothAdapter.STATE_OFF:
              sink.success(
                  Protos.BluetoothState.newBuilder().setState(Protos.BluetoothState.State.OFF).build().toByteArray());
              break;
            case BluetoothAdapter.STATE_TURNING_OFF:
              sink.success(Protos.BluetoothState.newBuilder().setState(Protos.BluetoothState.State.TURNING_OFF).build()
                  .toByteArray());
              break;
            case BluetoothAdapter.STATE_ON:
              sink.success(
                  Protos.BluetoothState.newBuilder().setState(Protos.BluetoothState.State.ON).build().toByteArray());
              break;
            case BluetoothAdapter.STATE_TURNING_ON:
              sink.success(Protos.BluetoothState.newBuilder().setState(Protos.BluetoothState.State.TURNING_ON).build()
                  .toByteArray());
              break;
          }
        }
      }
    };

    @Override
    public void onListen(Object o, EventChannel.EventSink eventSink) {
      sink = eventSink;
      IntentFilter filter = new IntentFilter(BluetoothAdapter.ACTION_STATE_CHANGED);
      activity.registerReceiver(mReceiver, filter);
    }

    @Override
    public void onCancel(Object o) {
      sink = null;
      activity.unregisterReceiver(mReceiver);
    }
  };

  private void startScan(MethodCall call, Result result) {
    try {
      terminalListManager.startTerminalsDiscovery();
      result.success(null);

    } catch (Exception e) {
      Log.d(TAG, "startScan error " + e.getMessage());  
      result.success(null);

      //result.error("startScan", e.getMessage(), e);
    }
  }

  @Override
  public void onListen(Object arguments, EventSink events) {
    Log.d(TAG, "ON LISTEN");
  }

  @Override
  public void onCancel(Object arguments) {

  }

  private void invokeMethodUIThread(final String name, final String result) {
    activity.runOnUiThread(new Runnable() {
      @Override
      public void run() {
        channel.invokeMethod(name, result);
      }
    });
  }

}
