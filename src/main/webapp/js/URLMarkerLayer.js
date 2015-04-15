URLMarkerLayer = SMC.layers.markers.MarkerLayer.extend(
    /** @lends SMC.layers.markers.WFSMarkerLayer# */
    {

        /**
         * Initialize the object with the params
         * @param {object} options - object with need parameters
         */
        initialize: function(options) {
            SMC.layers.markers.MarkerLayer.prototype.initialize.call(this, options);
            SMC.providers.URLFeatureProvider.prototype.initialize.call(this, options);
        },

        /**
         * Method to load the features into marker layer
         * @param {Object} features - Features to be loaded
         */
        onFeaturesLoaded: function(features) {
            this.addMarkerFromFeature(features);
        },

        /**
         * Retrieves the features from its source.
         */
        load: function() {
            this.loadFeatures();
        },

        /**
         * Method to create an HTML node for the name of the layer.
         * @returns {String} HTML code representing the code to be added to the layer's entry in the layer tree.
         */
        createNodeHTML: function() {
            return this.options.label || this.options.typeName;
        }

    }, [SMC.providers.URLFeatureProvider]);
