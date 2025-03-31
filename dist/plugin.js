var capacitorNdpsAESLibrary = (function (exports, core) {
    'use strict';

    const NdpsAESLibrary = core.registerPlugin('NdpsAESLibrary', {
        web: () => Promise.resolve().then(function () { return web; }).then(m => new m.NdpsAESLibraryWeb()),
    });

    class NdpsAESLibraryWeb extends core.WebPlugin {
        async echo(options) {
            return options;
        }
        async NdpsEncryption(options) {
            return options;
        }
        async NdpsDecryption(options) {
            return options;
        }
        async NdpsSigatureGeneration(options) {
            return options;
        }
        async NdpsAipayPayments(options) {
            return options;
        }
    }

    var web = /*#__PURE__*/Object.freeze({
        __proto__: null,
        NdpsAESLibraryWeb: NdpsAESLibraryWeb
    });

    exports.NdpsAESLibrary = NdpsAESLibrary;

    Object.defineProperty(exports, '__esModule', { value: true });

    return exports;

})({}, capacitorExports);
//# sourceMappingURL=plugin.js.map
