# openmpi-superbuild
OpenMPI superbuild

## Build

```
mkdir build; pushd build
cmake -DENABLE_openmpi=ON -DENABLE_cuda=ON -DENABLE_ucx=ON -DENABLE_efa=OFF -DENABLE_psm2=OFF ../openmpi-superbuild/
cmake --build . -- VERBOSE=true
ctest -R
popd
```

cuda support build requires PATH to nvcc and LD_LIBRARY_PATH to libcudart.so to be set

psm2 build requires hfi-devel package to be installed 

Select version to build -Dopenmpi_SOURCE_SELECTION=3.6.1

## References

- https://software.intel.com/en-us/articles/a-bkm-for-working-with-libfabric-on-a-cluster-system-when-using-intel-mpi-library
- https://hpcadvisorycouncil.atlassian.net/wiki/spaces/HPCWORKS/pages/13074505/MPI+Frameworks
- https://www.mellanox.com/related-docs/prod_acceleration_software/HPC-X_Toolkit_User_Manual_v2.3.pdf


## EFA notes

Install driver as per
https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/efa-start.html
Use this install option for gpu nodes
sudo ./efa_installer.sh -y --enable-gdr

## UCX Notes

-mca pml ucx --mca btl self -x UCX_TLS=rc,self,sm -x UCX_NET_DEVICES=mlx5_0:1

UCX + RoCEv2
check mode 

```
sudo cma_roce_mode -d mlx5_0 -p 1
```

-mca pml ucx --mca btl self -x UCX_TLS=rc,self,sm -x UCX_NET_DEVICES=mlx5_2:1 -x UCX_IB_GID_INDEX=3 -x UCX_IB_TRAFFIC_CLASS=104


## ROMIO NFS

Mount options noac,lock,local_local=none

## libfabric

fi_info  -e

Need to set FI_PROVIDER_PATH to lib/libfabric

