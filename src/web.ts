import { WebPlugin } from '@capacitor/core';
import { FileTransferPlugin } from './definitions';

export class FileTransferWeb extends WebPlugin implements FileTransferPlugin {
  constructor() {
    super({
      name: 'FileTransfer',
      platforms: ['web'],
    });
  }

  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
}

const FileTransfer = new FileTransferWeb();

export { FileTransfer };

import { registerWebPlugin } from '@capacitor/core';
registerWebPlugin(FileTransfer);
