sudo rpm-ostree override \
	remove kernel{,-core,-modules,-modules-extra} \
	--install http://karmatron.mooo.com/kernel-rt/kernel-rt-core-4.18.0-193.31.1.rt13.81.el8_2.ocptest.x86_64.rpm \
	--install http://karmatron.mooo.com/kernel-rt/kernel-rt-modules-4.18.0-193.31.1.rt13.81.el8_2.ocptest.x86_64.rpm \
	--install http://karmatron.mooo.com/kernel-rt/kernel-rt-modules-extra-4.18.0-193.31.1.rt13.81.el8_2.ocptest.x86_64.rpm \
	--install http://karmatron.mooo.com/kernel-rt/kernel-rt-modules-internal-4.18.0-193.31.1.rt13.81.el8_2.ocptest.x86_64.rpm

