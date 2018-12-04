set(CPACK_PACKAGE_FILE_NAME "openmpi")

# Install etc
install(DIRECTORY "${superbuild_install_location}/etc/"
	    DESTINATION "etc"
	        USE_SOURCE_PERMISSIONS
		    COMPONENT superbuild)

	    # Install share
	    install(DIRECTORY "${superbuild_install_location}/share/"
		        DESTINATION "share"
			    USE_SOURCE_PERMISSIONS
			        COMPONENT superbuild)

			# Install bin
			install(DIRECTORY "${superbuild_install_location}/bin/"
				    DESTINATION "bin"
				        USE_SOURCE_PERMISSIONS
					    COMPONENT superbuild)

				    # Install lib
				    install(DIRECTORY "${superbuild_install_location}/lib/"
					        DESTINATION "lib"
						    USE_SOURCE_PERMISSIONS
						        COMPONENT superbuild)
# Install include
install(DIRECTORY "${superbuild_install_location}/include/"
	    DESTINATION "include"
	        USE_SOURCE_PERMISSIONS
		    COMPONENT superbuild)
