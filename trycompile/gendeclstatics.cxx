/**
 * $Id$
 *
 * Copyright &copy; 2012-2014, Tech-X Corporation, Boulder, CO.
 * Arbitrary redistribution allowed provided this copyright remains.
 */

template <class TYPE> class X {
  public:
    static int r;
};
template <class TYPE> int X<TYPE>::r = 0;

int main (int argc, char* argv[]) {
  X<double> x;
  int rr = x.r + X<float>::r;
};

