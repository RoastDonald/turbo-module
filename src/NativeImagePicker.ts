import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';

export interface Spec extends TurboModule {
  getPermissionStatus(): string;
  requestPermission(): Promise<string>;
  pickImage(
    onSuccess: (uri: string) => void,
    onError: (error: string) => void
  ): void;
}

export default TurboModuleRegistry.getEnforcing<Spec>('ImagePicker');
