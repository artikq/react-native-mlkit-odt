// Contents of this file is adapted from https://github.com/agoldis/react-native-mlkit-ocr/blob/main/example/src/App.tsx

/* eslint-disable react-native/no-inline-styles */
import * as React from 'react';
import { StyleSheet, Button, SafeAreaView, Text } from 'react-native';
import {
  ImagePickerResponse,
  launchImageLibrary,
} from 'react-native-image-picker';
import MlkitOdt, { ObjectDetectorMode } from 'react-native-mlkit-odt';

export default function App() {
  const [result, setResult] = React.useState<any | undefined>();
  const [, setImage] = React.useState<ImagePickerResponse | undefined>();
  if (result) {
    console.log('[RESULT]', result);
  }
  return (
    <SafeAreaView style={styles.container}>
      <Text>{JSON.stringify(result)}</Text>
      <Button
        onPress={() => launchGallery(setResult, setImage)}
        title="Start"
      />
    </SafeAreaView>
  );
}

function launchGallery(
  setResult: (result: any) => void,
  setImage: (result: ImagePickerResponse) => void
) {
  setResult([{ type: 'no-result' }]);
  launchImageLibrary(
    {
      mediaType: 'photo',
    },
    async (response: ImagePickerResponse) => {
      if (!response.uri) {
        throw new Error('oh!');
      }
      try {
        setImage(response);
        setResult(
          await MlkitOdt.detectFromUri(response.uri, {
            detectorMode: 1,
            shouldEnableClassification: true,
            shouldEnableMultipleObjects: true,
          })
        );
      } catch (e) {
        console.error(e);
      }
    }
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
  },
  scroll: {
    width: '100%',
    borderColor: 'red',
    borderWidth: 1,
  },
});
