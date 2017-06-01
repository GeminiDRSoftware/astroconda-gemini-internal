:
# AstroConda version of the setup script for our /astro/iraf server installs
# (essentially determines the right path for the OS & sources "activate").

basepath="/astro/iraf"
acdir="anaconda2_${ACVER}"

# Default to "internal" env version unless otherwise specified. This value can
# either be dev/internal/gnops/gsops (in which case the dated env to be used is
# defined by the appropriate link under /astro/iraf/platform), or it can have
# "_YYYYMMDD" appended (in which case that dated env is looked up directly).
if [ -n "$GEMVER" ]; then
    gemver=$(echo "$GEMVER" | tr 'A-Z' 'a-z')
else
    gemver=internal
fi

status=0

# Determine the current platform. Unfortunately, we have to replicate conda's
# OS detection logic because we can't actually run conda until we determine
# which Anaconda architecture to use. This is similar to my IRAF "setup".
case $(uname -m) in
    i386|i686)
        bits=32 ;;
    x86_64)
        bits=64 ;;
    *)
        status=1 ;;
esac
case $(uname -s | tr 'A-Z' 'a-z') in
    linux)
        os=linux ;;
    darwin)
        os=osx; bits=64 ;;  # 32-bit osx can still run the 64-bit, only version
    *)
        status=1 ;;
esac
platform=${os}-${bits}

# Configure the environment only if the platform is recognized (don't "exit"
# above, since this script is intended to be sourced from the user's shell).
if [ $status -eq 0 ]; then

    # The default anaconda installation & environment (ie. Gemini package
    # versions) are determined by the symlinks defined in /astro/iraf unless
    # the user overrides them with ACVER or GEMVER.
    if [ -n "$ACVER" ]; then
        acpath="${basepath}/${platform}/${acdir}"
    else
        acpath="${basepath}/${platform}/anaconda" # "activate" follows the link
    fi

    # If Gemini tag has date attached, look up the corresponding env directly
    # in anaconda/envs/, otherwise follow the link under /astro/iraf/$platform.
    # (Conda's activate actually follows links directly when given a full path,
    # but that seems to be an undocumented feature, so do it here explicitly):
    if echo "$gemver" | egrep -q "[-_][0-9]{8}"; then
        envpath="${acpath}/envs/${gemver}"
        envname=${gemver}
    else
        envpath="${basepath}/${platform}/${gemver}"
        if targ=$(readlink "${envpath}"); then
            envname=$(basename "$targ")
            if [ -n "$ACVER" ]; then
                # It would be nice to issue this warning only if the versions
                # mismatch, but checking that is a bit of a faff (& specifying
                # ACVER without a GEMVER date is probably a mistake anyway).
                echo "WARNING: ACVER=$ACVER overridden by $gemver -> $targ" >&2
            fi
        else
            status=1
        fi
    fi

    # Activate the target environment, if it exists:
    if [ $status -eq 0 -a -r "$envpath/bin/activate" ]; then

        # Sourcing activate from the environment itself allows different
        # dev/internal/gnops/gsops links to point to different base anaconda
        # installations, where needed (transitionally):
        . "${envpath}/bin/activate" "$envname"

        # This would likely break the installation if set (the same can be true
        # of PYTHONPATH if it contains standard dependencies, but we leave that
        # one to the user, who may have legitimate reasons for setting it).
        unset LD_LIBRARY_PATH

    else
        echo "Environment not found: $envpath" >&2
        echo "(try unsetting GEMVER / ACVER variables to get the default)" >&2
        status=1
    fi

else
    echo "Unsupported platform: $(uname -sm)" >&2
fi

unset basepath os bits platform acdir acpath gemver envpath envname targ

