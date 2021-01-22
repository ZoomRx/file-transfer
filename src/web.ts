import { WebPlugin } from '@capacitor/core';
import { FileTransferPlugin } from './definitions';

export class FileTransferWeb extends WebPlugin implements FileTransferPlugin {
  constructor() {
    super({
      name: 'FileTransfer',
      platforms: ['web'],
    });
  }

  async download(_data: { src: string, destination: string, objectId: String, options:object}): Promise<void> {
    return new Promise((_resolve, reject) => reject);
  }

  async upload(_data: { src: string, destination: string, objectId: String, options:object}): Promise<void> {
    return new Promise((_resolve, reject) => reject);
  }

  async abort(_data: {objectId: String}): Promise<void> {
    return new Promise((_resolve, reject) => reject);
  }
}

const FileTransfer = new FileTransferWeb();

export { FileTransfer };

import { registerWebPlugin } from '@capacitor/core';
registerWebPlugin(FileTransfer);
