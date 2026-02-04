@EndUserText.label: 'file upload'
define root abstract entity ZI_FILE_upload
{
  // Dummy is a dummy field
  @UI.hidden        : true
  dummy             : abap_boolean;
  _StreamProperties : association [1] to ZI_FILE_STREAM on 1 = 1;
}
