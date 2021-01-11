declare module '@capacitor/core' {
  interface PluginRegistry {
    FileTransfer: FileTransferPlugin;
  }
}

export interface FileTransferPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
}
