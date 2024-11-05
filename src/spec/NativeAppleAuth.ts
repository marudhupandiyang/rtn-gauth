import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';

export interface Spec extends TurboModule {
  performRequest(params: Object): Promise<Object>;
}

export const NativeModuleApple =
  TurboModuleRegistry.getEnforcing<Spec>('RNAppleAuth');
