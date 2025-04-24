import { useState } from 'react';
import { Button, Image, StyleSheet, View } from 'react-native';
import {
  getPermissionStatus,
  pickImage,
  requestPermission,
} from 'react-native-image-picker';

export default function App() {
  const [url, setUrl] = useState<string | null>(null);
  return (
    <View style={styles.container}>
      <Button
        title="Request Permission"
        onPress={async () => {
          const status = await requestPermission();
          console.log('Permission Status:', status);
        }}
      />
      <Button
        title="Get Permission Status"
        onPress={async () => {
          const status = getPermissionStatus();
          console.log('Permission Status11:', status);
        }}
      />
      <Button
        title="Pick Image"
        onPress={async () => {
          pickImage(
            (uri) => {
              setUrl(uri);
            },
            (error) => {
              console.error('Error picking image:', error);
            }
          );
        }}
      />
      {url && (
        <Image
          source={{ uri: url }}
          style={{ width: 200, height: 200 }}
          resizeMode="contain"
        />
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
});
