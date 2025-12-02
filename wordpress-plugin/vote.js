jQuery(function($){
  $(document).on('submit', '.fr-ref-form', function(e){
    e.preventDefault();
    const form = $(this);
    const referendumId = form.data('referendum');
    const choiceId = form.find('input[name="choice"]:checked').val();
    if (!choiceId) { alert('Sélectionnez une option'); return; }
    $.post(frRefData.ajaxUrl, {
      action: 'submit_referendum_vote',
      nonce: frRefData.nonce,
      referendum_id: referendumId,
      choice_id: choiceId
    }).done(function(){
      alert('Vote enregistré');
      location.reload();
    }).fail(function(xhr){
      alert('Erreur: ' + xhr.responseText);
    });
  });
});
