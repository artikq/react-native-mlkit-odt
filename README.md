# react-native-mlkit-odt

React native google mlkit odt bindings

## Installation

```sh
npm install react-native-mlkit-odt
```

## Usage

```js
import MlkitOdt, { ObjectDetectorMode } from 'react-native-mlkit-odt';

const result = await MlkitOdt.detectFromUri(uri, {
  detectorMode: ObjectDetectorMode.SINGLE_IMAGE,
  shouldEnableClassification: true,
  shouldEnableMultipleObjects: true,
});
// OR detect with default config
const result = await MlkitOdt.detectFromUri(uri);
```

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT
