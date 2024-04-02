PacketHeaderClass::PacketHeaderClass(const char* classname, int hdrlen) :
    TclClass(classname), hdrlen_(hdrlen), offset_(0)
{ }

TclObject* PacketHeaderClass::create(int, const char*const*)
{
    return (0);
}

void PacketHeaderClass::bind()
{
    TclClass::bind();
    Tcl& tcl = Tcl::instance();
    tcl.evalf("%s set hdrlen_ %d", classname_, hdrlen_);
    export_offsets();
    add_method("offset");
}

void PacketHeaderClass::export_offsets()
{ }

void PacketHeaderClass::field_offset(const char* fieldname, int offset)
{
    Tcl& tcl = Tcl::instance();
    tcl.evalf("%s set offset_(%s) %d", classname_, fieldname, offset);
}

int PacketHeaderClass::method(int ac, const char*const* av)
{
    Tcl& tcl = Tcl::instance();
    int argc = ac - 2;
    const char*const* argv = av + 2;
    
    if (argc == 3) {
        if (strcmp(argv[1], "offset") == 0) {
            if (offset_) {
                *offset_ = atoi(argv[2]);
                return TCL_OK;
            }
            tcl.resultf("Warning: cannot set offset_ for %s", classname_);
            return TCL_OK;
        }
    }
    else if (argc == 2) {
        if (strcmp(argv[1], "offset") == 0) {
            if (offset_) {
                tcl.resultf("%d", *offset_);
                return TCL_OK;
            }
        }
    }
    return TclClass::method(argc, argv);
}
