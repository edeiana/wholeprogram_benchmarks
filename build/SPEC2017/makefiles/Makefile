BENCHMARK=test
LIBS=-lm -mcmodel=large -lstdc++ -lpthread
#-L../../parsec-3.0/pkgs/apps/x264/inst/amd64-linux.gclang/lib -lx264 -L/usr/lib64 -L/usr/lib
#-noelle-disable-loop-aware-dependence-analyses for x264

all: memorytool-all

memorytool-all:
	PROGRAM_LIBS="$(LIBS)" $@ $(BENCHMARK).bc

memorytool-accelerator:
	PROGRAM_LIBS="$(LIBS)" $@ $(BENCHMARK).bc

memorytool-criticalsection:
	PROGRAM_LIBS="$(LIBS)" $@ $(BENCHMARK).bc

memorytool-statesizes:
	PROGRAM_LIBS="$(LIBS)" $@ $(BENCHMARK).bc

memorytool-stateprivatization:
	PROGRAM_LIBS="$(LIBS)" $@ $(BENCHMARK).bc

memorytool-referencecycles:
	PROGRAM_LIBS="$(LIBS)" $@ $(BENCHMARK).bc

memorytool-stats:
	PROGRAM_LIBS="$(LIBS)" $@ $(BENCHMARK).bc

clean:
	rm -rf ./$(BENCHMARK) ./$(BENCHMARK)_after_pass.bc ./$(BENCHMARK)_after_pass_O3 ./$(BENCHMARK)_after_pass_O3_binary ./*.symbol ./*.o ./*.ll ./*.json ./*.oracle

.PHONY: all clean memorytool-stateprivatization memorytool-referencecycles
