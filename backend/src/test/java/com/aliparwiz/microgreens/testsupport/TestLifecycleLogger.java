package com.aliparwiz.microgreens.testsupport;

import org.junit.jupiter.api.extension.AfterTestExecutionCallback;
import org.junit.jupiter.api.extension.BeforeTestExecutionCallback;
import org.junit.jupiter.api.extension.ExtensionContext;

class TestLifecycleLogger implements BeforeTestExecutionCallback, AfterTestExecutionCallback {

    @Override
    public void beforeTestExecution(ExtensionContext context) {
        String className = context.getRequiredTestClass().getSimpleName();
        String testName = context.getDisplayName();
        System.out.printf("[TEST][START] %s -> %s%n", className, testName);
    }

    @Override
    public void afterTestExecution(ExtensionContext context) {
        String className = context.getRequiredTestClass().getSimpleName();
        String testName = context.getDisplayName();
        Throwable failure = context.getExecutionException().orElse(null);
        if (failure == null) {
            System.out.printf("[TEST][PASS ] %s -> %s%n", className, testName);
        } else {
            System.out.printf("[TEST][FAIL ] %s -> %s (%s)%n",
                    className,
                    testName,
                    failure.getClass().getSimpleName());
        }
    }
}
