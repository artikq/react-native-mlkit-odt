package com.reactnativemlkitodt

import android.graphics.Rect
import android.net.Uri
import com.facebook.react.bridge.*
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.objects.*
import com.google.mlkit.vision.objects.defaults.ObjectDetectorOptions
import java.lang.Exception

class MlkitOdtModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {

  override fun getName(): String {
    return "MlkitOdt"
  }

  @ReactMethod
  fun detectFromUri(uri: String, isSingleImageMode: Int, enableClassification: Int, enableMultiDetect: Int, promise: Promise) {
    val image: InputImage;
    try {
      val optionsBuilder = ObjectDetectorOptions.Builder()
      if (isSingleImageMode == 1) {
        optionsBuilder.setDetectorMode(ObjectDetectorOptions.SINGLE_IMAGE_MODE)
      }
      if (enableClassification == 1) {
        optionsBuilder.enableClassification()
      }
      if (enableMultiDetect == 1) {
        optionsBuilder.enableMultipleObjects()
      }
      image = InputImage.fromFilePath(reactApplicationContext, Uri.parse(uri));
      val objectDetector = ObjectDetection.getClient(optionsBuilder.build())
      objectDetector.process(image).addOnSuccessListener { detectedObjects ->
        promise.resolve(makeResultObject(detectedObjects))
      }.addOnFailureListener { e ->
        promise.reject(e);
        e.printStackTrace();
      }
    } catch (e: Exception) {
      promise.reject(e);
      e.printStackTrace();
    }
  }

  private fun makeResultObject(objects: List<DetectedObject>): WritableArray {
    val data: WritableArray = Arguments.createArray()
    for (detectedObject in objects) {
      val outputObject = Arguments.createMap()
      outputObject.putMap("bounding", getBoundingResult(detectedObject.boundingBox))
      if (detectedObject.trackingId != null)
        outputObject.putString("trackingID", detectedObject.trackingId?.toString())
      val labels = Arguments.createArray()
      detectedObject.labels.forEach { l ->
        val lbl = Arguments.createMap()
        lbl.putString("text", l.text)
        lbl.putString("index", l.index?.toString())
        lbl.putString("confidence", l.confidence?.toString())
        labels.pushMap(lbl)
      }
      outputObject.putArray("labels", labels)
      data.pushMap(outputObject)
    }
    return data
  }

  private fun getBoundingResult(boundingBox: Rect): WritableMap {
    val coordinates: WritableMap = Arguments.createMap()
    coordinates.putInt("originY", boundingBox.top)
    coordinates.putInt("originX", boundingBox.left)
    coordinates.putInt("width", boundingBox.width())
    coordinates.putInt("height", boundingBox.height())
    return coordinates;
  }
}
