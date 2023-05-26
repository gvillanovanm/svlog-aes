main:
	g++ -Wall -std=c++0x -o prog main.cpp -lcryptopp
	./prog
install:
	sudo yum install cryptopp cryptopp-devel
help:
	@echo "Type make main to compile your C main function to test the refmod functions"
	@echo "type make refmod to compile and run the SV refmod function"
	@echo "Type make clean to clean the files"
clean:
	rm -rf prog
