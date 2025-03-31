export interface NdpsAESLibraryPlugin {
    echo(options: {
        value: string;
    }): Promise<{
        value: string;
    }>;
    NdpsEncryption(options: {
        value: string;
        encryptionKey: string;
    }): Promise<{
        value: string;
    }>;
    NdpsDecryption(options: {
        value: string;
        decryptionKey: string;
    }): Promise<{
        value: string;
    }>;
    NdpsSigatureGeneration(options: {
        value: string;
        respHashKey: string;
    }): Promise<{
        value: string;
    }>;
    NdpsAipayPayments(options: {
        value: object;
    }): Promise<{
        value: object;
    }>;
}
