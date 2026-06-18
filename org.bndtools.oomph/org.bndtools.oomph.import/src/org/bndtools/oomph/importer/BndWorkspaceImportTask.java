package org.bndtools.oomph.importer;

import java.io.IOException;
import java.lang.reflect.Method;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.atomic.AtomicReference;

import org.eclipse.oomph.setup.SetupTaskContext;
import org.eclipse.oomph.setup.impl.SetupTaskImpl;

public class BndWorkspaceImportTask extends SetupTaskImpl {

    private static final String BNDTOOLS_IMPORT_WIZARD_ID = "bndtools.importProject";

    @Override
    public int getProgressMonitorWork() {
        return 1;
    }

    @Override
    public boolean isNeeded(SetupTaskContext context) {
        return true;
    }

    @Override
    public void perform(SetupTaskContext context) throws Exception {
        context.log("Launching Bndtools Existing Bnd Workspace import wizard");
        launchBndtoolsImportWizard();
    }

    private void launchBndtoolsImportWizard() throws Exception {
        Object workbench = invokeStatic("org.eclipse.ui.PlatformUI", "getWorkbench");
        Object display = invoke(workbench, "getDisplay");

        AtomicReference<Exception> failure = new AtomicReference<>();
        AtomicInteger dialogResult = new AtomicInteger(Integer.MIN_VALUE);

        Method syncExecMethod = display.getClass().getMethod("syncExec", Runnable.class);
        syncExecMethod.invoke(display, (Runnable) () -> {
            try {
                Object wizard = createImportWizard(workbench, BNDTOOLS_IMPORT_WIZARD_ID);
                Object window = invoke(workbench, "getActiveWorkbenchWindow");
                Object shell = invoke(window, "getShell");

                Class<?> iWizardClass = Class.forName("org.eclipse.jface.wizard.IWizard");
                Class<?> wizardDialogClass = Class.forName("org.eclipse.jface.wizard.WizardDialog");
                Object dialog = wizardDialogClass.getConstructor(Class.forName("org.eclipse.swt.widgets.Shell"), iWizardClass)
                    .newInstance(shell, wizard);

                int result = (Integer) invoke(dialog, "open");
                dialogResult.set(result);
            } catch (Exception e) {
                failure.set(e);
            }
        });

        if (failure.get() != null) {
            throw failure.get();
        }

        int okValue = (Integer) Class.forName("org.eclipse.jface.window.Window").getField("OK").get(null);
        if (dialogResult.get() != okValue) {
            throw new IOException("Bndtools Existing Bnd Workspace import was cancelled or did not complete");
        }
    }

    private Object createImportWizard(Object workbench, String wizardId) throws Exception {
        Object importWizardRegistry = invoke(workbench, "getImportWizardRegistry");
        Object wizardDescriptor = invoke(importWizardRegistry, "findWizard", String.class, wizardId);

        if (wizardDescriptor == null) {
            throw new IOException("Bndtools import wizard not found: " + wizardId);
        }

        Object wizard = invoke(wizardDescriptor, "createWizard");

        Class<?> importWizardType = Class.forName("org.eclipse.ui.IImportWizard");
        if (importWizardType.isInstance(wizard)) {
            Object emptySelection = Class.forName("org.eclipse.jface.viewers.StructuredSelection").getField("EMPTY").get(null);
            importWizardType.getMethod("init", Class.forName("org.eclipse.ui.IWorkbench"), Class.forName("org.eclipse.jface.viewers.IStructuredSelection"))
                .invoke(wizard, workbench, emptySelection);
        }

        return wizard;
    }

    private static Object invokeStatic(String className, String methodName) throws Exception {
        Class<?> clazz = Class.forName(className);
        Method method = clazz.getMethod(methodName);
        return method.invoke(null);
    }

    private static Object invoke(Object target, String methodName) throws Exception {
        Method method = target.getClass().getMethod(methodName);
        return method.invoke(target);
    }

    private static Object invoke(Object target, String methodName, Class<?> argType, Object arg) throws Exception {
        Method method = target.getClass().getMethod(methodName, argType);
        return method.invoke(target, arg);
    }
}

