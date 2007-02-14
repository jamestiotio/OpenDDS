// -*- C++ -*-
//
// $Id$

#include "FooTypeSupportImpl.h"
#include "dds/DCPS/Registered_Data_Types.h"
#include "dds/DdsDcpsDomainC.h"
#include "dds/DCPS/Service_Participant.h"

#include "FooDataWriterImpl.h"
#include "FooDataReaderImpl.h"

// Implementation skeleton constructor
FooTypeSupportImpl::FooTypeSupportImpl (void)
  {
  }

// Implementation skeleton destructor
FooTypeSupportImpl::~FooTypeSupportImpl (void)
  {
  }

DDS::ReturnCode_t
FooTypeSupportImpl::register_type (
    ::DDS::DomainParticipant_ptr participant,
    const char * type_name
  )
{
  CORBA::String_var tn;
  if (type_name == 0 || type_name[0] == '\0')
     tn = this->get_type_name ();
  else
     tn = CORBA::string_dup (type_name);

  return ::TAO::DCPS::Registered_Data_Types->register_type(participant,
                                                           tn.in (),
                                                           this);
}


char *
FooTypeSupportImpl::get_type_name (
  )
{
  return CORBA::string_dup (this->_interface_repository_id());
}


::TAO::DCPS::DataWriterRemote_ptr FooTypeSupportImpl::create_datawriter (
  )
  {
    FooDataWriterImpl* writer_impl;
    ACE_NEW_RETURN(writer_impl,
                    FooDataWriterImpl(),
                    ::TAO::DCPS::DataWriterRemote::_nil());

    ::TAO::DCPS::DataWriterRemote_ptr writer_obj
      = ::TAO::DCPS::servant_to_reference (writer_impl);

    return writer_obj;
  }

::TAO::DCPS::DataReaderRemote_ptr FooTypeSupportImpl::create_datareader (
  )
  {
    FooDataReaderImpl* reader_impl;
    ACE_NEW_RETURN(reader_impl,
                    FooDataReaderImpl(),
                    ::TAO::DCPS::DataReaderRemote::_nil());


    ::TAO::DCPS::DataReaderRemote_ptr reader_obj
      = ::TAO::DCPS::servant_to_reference (reader_impl);

    return reader_obj;
  }


