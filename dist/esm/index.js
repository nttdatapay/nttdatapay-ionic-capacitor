import { registerPlugin } from '@capacitor/core';
const NdpsAESLibrary = registerPlugin('NdpsAESLibrary', {
    web: () => import('./web').then(m => new m.NdpsAESLibraryWeb()),
});
export * from './definitions';
export { NdpsAESLibrary };
//# sourceMappingURL=index.js.map