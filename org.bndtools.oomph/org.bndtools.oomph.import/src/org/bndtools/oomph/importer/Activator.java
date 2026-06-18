package org.bndtools.oomph.importer;

public class Activator {

    public static final String PLUGIN_ID = "org.bndtools.oomph.import";

    private static Activator instance;

    public void start() {
        instance = this;
    }

    public void stop() {
        instance = null;
    }

    public static Activator getDefault() {
        return instance;
    }
}
