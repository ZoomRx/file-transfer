declare module '@capacitor/core' {
  interface PluginRegistry {
    FileTransfer: FileTransferPlugin;
  }
}

export interface FileTransferPlugin {
  download(data: { src: string, destination: string, objectId: String, options:object}): Promise<void>;
  upload(data: { src: string, destination: string, objectId: String, options:object}): Promise<void>;
  abort(data: {objectId: String}): Promise<void>;
}
