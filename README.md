# openmpi-superbuild
OpenMPI superbuild

mkdir build; pushd build
cmake -DENABLE_openmpi=ON -DENABLE_cuda=ON -DENABLE_ucx=ON -DENABLE_psm2=OFF ../openmpi-superbuild/
cmake --build . -- VERBOSE=true
ctest -R
popd

References

https://software.intel.com/en-us/articles/a-bkm-for-working-with-libfabric-on-a-cluster-system-when-using-intel-mpi-library

https://hpcadvisorycouncil.atlassian.net/wiki/spaces/HPCWORKS/pages/13074505/MPI+Frameworks

UCX Notes

-mca pml ucx --mca btl self -x UCX_TLS=rc,self,sm -x UCX_NET_DEVICES=mlx5_0:1

UCX + RoCEv2
check support > sudo cma_roce_mode -d mlx5_0 -p 1
-mca pml ucx --mca btl self -x UCX_TLS=rc,self,sm -x UCX_NET_DEVICES=mlx5_2:1 -x UCX_IB_GID_INDEX=3 -x UCX_IB_TRAFFIC_CLASS=104

https://www.mellanox.com/related-docs/prod_acceleration_software/HPC-X_Toolkit_User_Manual_v2.2.pdf
