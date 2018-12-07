# openmpi-superbuild
OpenMPI superbuild

https://software.intel.com/en-us/articles/a-bkm-for-working-with-libfabric-on-a-cluster-system-when-using-intel-mpi-library

UCX Notes

-mca pml ucx --mca btl self -x UCX_TLS=rc,self,sm -x UCX_NET_DEVICES=mlx5_0:1

UCX + RoCEv2

-mca pml ucx --mca btl self -x UCX_TLS=rc,self,sm -x UCX_NET_DEVICES=mlx5_2:1 -x UCX_IB_GID_INDEX=3 -x UCX_IB_TRAFFIC_CLASS=104

https://www.mellanox.com/related-docs/prod_acceleration_software/HPC-X_Toolkit_User_Manual_v2.2.pdf
