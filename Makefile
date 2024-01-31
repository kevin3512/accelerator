#-------------------------------------------------------------------------------------------------------
comp  : clean vcs
#-------------------------------------------------------------------------------------------------------
vcs   :
	vcs  \
		-f filelist.f  \
		-timescale=1ns/1ns \
		-full64  -R  +vc  +v2k  -sverilog -debug_access+all\
		|  tee  vcs.log 
#vcs2 use to compile PuDianNao relate code
vcs2   :
	vcs  \
		-f filelist2.f  \
		-timescale=1ns/1ns \
		-full64  -R  +vc  +v2k  -sverilog -debug_access+all\
		|  tee  vcs.log 

vcs_c   :
	vcs  \
		-f $(filelist)  \
		-timescale=1ns/1ns \
		-full64  -R  +vc  +v2k  -sverilog -debug_access+all\
		|  tee  vcs.log 
#-------------------------------------------------------------------------------------------------------
verdi  :
	verdi -f filelist.f -ssf tb.fsdb &
#verdi2 use to check PuDianNao relate wave file
verdi2  :
	verdi -f filelist2.f -ssf tb2.fsdb &

verdi_c  :
	verdi -f filelist.f -ssf $(tb) &
#-------------------------------------------------------------------------------------------------------
clean  :
	 rm  -rf  *~  core  csrc  simv*  vc_hdrs.h  ucli.key  urg* *.log  novas.* *.fsdb* verdiLog  64* DVEfiles *.vpd
#-------------------------------------------------------------------------------------------------------
cp     :
	cp -rf /mnt/hgfs/Verilog\ workspace/accelerator/ ../
#-------------------------------------------------------------------------------------------------------


