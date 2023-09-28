rm -Rf custom-jvm

EXCLUDE_MODULES="java.compiler java.scripting jdk.javadoc jdk.jdwp.agent java.rmi java.management.rmi jdk.compiler jdk.jshell jdk.attach jdk.editpad jdk.jconsole jdk.jdeps jdk.jlink jdk.jdi jdk.jpackage jdk.jsobject jdk.jartool jdk.jstatd jdk.management.agent"

#Generate full list of modules:
MOD_ALL=$(java ModulesList.java $EXCLUDE_MODULES)

echo "Generating optimised JVM with modules: $MOD_ALL"

# Used by JPackage:
# --strip-native-commands --strip-debug --no-man-pages --no-header-files

# JLink tuning:
JLINK_OPTS="--strip-debug --no-man-pages --no-header-files --strip-native-debug-symbols exclude-debuginfo-files --compress 0 --dedup-legal-notices error-if-not-same-content"

## Notes
# --compress 0 seems to save more RSS at runtime than --compress 1, but makes the modules file large: 79MB
# --compress 2 seems to have the worst metrics (but clearly it's smaller: 36MB for modules)
# a regular (non-jlink) JDK seems to get similar RSS metrics as compress=2

jlink --add-modules $MOD_ALL $JLINK_OPTS --output custom-jvm

# Fun to try:
# --vm server --strip-native-commands

NEWJDK="$(pwd)/custom-jvm"

export JAVA_ROOT=$NEWJDK
export JAVA_HOME=$NEWJDK
export JAVA_BINDIR=$NEWJDK/bin
export PATH=$JAVA_BINDIR:$PATH

pushd ~/sources/quarkus-quickstarts/getting-started
numactl --localalloc -N 0 java -XX:+AlwaysPreTouch -XX:+UseG1GC -Xmx20M -Xms20M -jar target/quarkus-app/quarkus-run.jar
popd



