sudo rpm-ostree override \
	remove kernel{,-core,-modules,-modules-extra} \
	--install http://download.eng.bos.redhat.com/brewroot/work/tasks/9152/33029152/kernel-rt-core-4.18.0-193.31.1.rt13.81.el8_2.ocptest.x86_64.rpm \
	--install http://download.eng.bos.redhat.com/brewroot/work/tasks/9152/33029152/kernel-rt-modules-4.18.0-193.31.1.rt13.81.el8_2.ocptest.x86_64.rpm \
	--install http://download.eng.bos.redhat.com/brewroot/work/tasks/9152/33029152/kernel-rt-modules-extra-4.18.0-193.31.1.rt13.81.el8_2.ocptest.x86_64.rpm \
	--install http://download.eng.bos.redhat.com/brewroot/work/tasks/9152/33029152/kernel-rt-modules-internal-4.18.0-193.31.1.rt13.81.el8_2.ocptest.x86_64.rpm

