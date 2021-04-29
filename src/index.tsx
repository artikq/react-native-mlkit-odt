import { NativeModules } from 'react-native';
const { MlkitOdt } = NativeModules;

export type DetectedObjectBounding = {
  originY: number;
  originX: number;
  height: number;
  width: number;
};
export type DetectedObjectLabel = {
  text?: string;
  confidence?: string;
  index?: string;
};
export type ObjectDetectionResult = {
  bounding: DetectedObjectBounding;
  trackingID?: string;
  labels: DetectedObjectLabel[];
};

export enum ObjectDetectorMode {
  STREAM = 0,
  SINGLE_IMAGE = 1,
}
export type ObjectDetectorOptions = {
  detectorMode: ObjectDetectorMode;
  shouldEnableClassification: boolean;
  shouldEnableMultipleObjects: boolean;
};
const defaultOptions: ObjectDetectorOptions = {
  detectorMode: ObjectDetectorMode.STREAM,
  shouldEnableClassification: false,
  shouldEnableMultipleObjects: false,
};

const wrapper = {
  detectFromUri: async (
    uri: string,
    config: ObjectDetectorOptions = defaultOptions
  ): Promise<ObjectDetectionResult[]> =>
    MlkitOdt.detectFromUri(
      uri,
      config.detectorMode === 0 || config.detectorMode === 1
        ? config.detectorMode
        : defaultOptions.detectorMode,
      config.shouldEnableClassification ? 1 : 0,
      config.shouldEnableMultipleObjects ? 1 : 0
    ),
};

type MlkitOdtType = typeof wrapper;

export default wrapper as MlkitOdtType;
