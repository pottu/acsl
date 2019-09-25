#include <stdexcept>

class Array {
public:
  int* data;
  int data_length;

  /*@ behavior good:
    assume 0 <= index < data_length;
    ensures \result == data[index];
    throws \false;
    behavior bad:
    assume !( 0 <= index < data_length );
    ensures \false;
    throws \true;
    @*/
  int getValue(int index) {
    if (index < 0) throw std::range_error("negative index");
    if (index >= data_length) throw std::range_error("index too large");

    return data[index];
  }
};