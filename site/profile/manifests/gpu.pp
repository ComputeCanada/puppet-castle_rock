class profile::gpu {
  $cuda_ver = '10.1.168-1'
  $driver_ver = '418.67'
  package { 'cuda-repo':
    ensure   => 'installed',
    provider => 'rpm',
    name     => 'cuda-repo-rhel7',
    source   => "http://developer.download.nvidia.com/compute/cuda/repos/rhel7/x86_64/cuda-repo-rhel7-${cuda_ver}.x86_64.rpm"
  }

  package { [
    'nvidia-driver-cuda-libs',
    'nvidia-driver-NVML',
    'nvidia-driver-NvFBCOpenGL',
    'nvidia-driver-libs',
    'nvidia-driver-devel',
    ]:
    ensure  => 'installed',
    require => Package['cuda-repo']
  }

  if $facts['nvidia_gpu_count'] > 0 {
    package { 'kernel-devel':
      ensure => 'installed'
    }

    package { [
        'nvidia-driver',
        'nvidia-driver-cuda',
        'dkms-nvidia',
        'nvidia-modprobe',
      ]:
      ensure  => 'installed',
      require => [Package['cuda-repo'], Package['kernel-devel']]
    }

    kmod::load { [
      'nvidia',
      'nvidia_drm',
      'nvidia_modeset',
      'nvidia_uvm'
      ]:
    }
  }

  file { '/usr/lib64/nvidia':
    ensure => directory
  }

  $nvidia_libs = [
    "libnvidia-ml.so.${driver_ver}", 'libnvidia-ml.so.1', 'libnvidia-fbc.so.1',
    "libnvidia-fbc.so.${driver_ver}", 'libnvidia-ifr.so.1', "libnvidia-ifr.so.${driver_ver}",
    'libcuda.so', 'libcuda.so.1', "libcuda.so.${driver_ver}", "libnvcuvid.so.${driver_ver}",
    'libnvcuvid.so.1', "libnvidia-compiler.so.${driver_ver}", 'libnvidia-encode.so.1',
    "libnvidia-encode.so.${driver_ver}", "libnvidia-fatbinaryloader.so.${driver_ver}",
    'libnvidia-opencl.so.1', "libnvidia-opencl.so.${driver_ver}", 'libnvidia-opticalflow.so.1',
    "libnvidia-opticalflow.so.${driver_ver}", 'libnvidia-ptxjitcompiler.so.1', "libnvidia-ptxjitcompiler.so.${driver_ver}",
    'libnvcuvid.so', 'libnvidia-cfg.so', 'libnvidia-encode.so',
    'libnvidia-fbc.so', 'libnvidia-ifr.so', 'libnvidia-ml.so',
    'libnvidia-ptxjitcompiler.so', 'libEGL_nvidia.so.0', "libEGL_nvidia.so.${driver_ver}",
    'libGLESv1_CM_nvidia.so.1', "libGLESv1_CM_nvidia.so.${driver_ver}", 'libGLESv2_nvidia.so.2',
    "libGLESv2_nvidia.so.${driver_ver}", 'libGLX_indirect.so.0', 'libGLX_nvidia.so.0',
    "libGLX_nvidia.so.${driver_ver}", "libnvidia-cbl.so.${driver_ver}", 'libnvidia-cfg.so.1',
    "libnvidia-cfg.so.${driver_ver}", "libnvidia-eglcore.so.${driver_ver}", "libnvidia-glcore.so.${driver_ver}",
    "libnvidia-glsi.so.${driver_ver}", "libnvidia-glvkspirv.so.${driver_ver}", "libnvidia-rtcore.so.${driver_ver}",
    "libnvidia-tls.so.${driver_ver}", 'libnvoptix.so.1', "libnvoptix.so.${driver_ver}"]

  $nvidia_libs.each |String $lib| {
    file { "/usr/lib64/nvidia/${lib}":
      ensure  => link,
      target  => "/usr/lib64/${lib}",
      seltype => 'lib_t'
    }
  }

}