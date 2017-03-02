RULESET_ID = 518
ROSTER_ID = 1230
GALLERY_HOME_FOLDER_ID = 0
GALLERY_TARGET_FOLDER_ID = 10357


if __name__ == '__main__':

  import sys

  try:
    import fumbbl_session
  except ImportError:
    print(
        'Please install the fumbbl_session module.\n'
        'Note that it is not a public library.\n'
        'Please contact with SzieberthAdam.'
      )
    sys.exit()

  if len(sys.argv) != 3:
    print('Usage: python make_new_stoneset.py <name> <pw>')
    sys.exit()

  name, pw = sys.argv[1:]
  print('logging in... ', end='')
  sys.stdout.flush()
  s = fumbbl_session.log_in(name, pw)
  print('done.')

  print('getting existing images in the gallery '
      'home folder... ', end='')
  sys.stdout.flush()
  existing_imgs = {img.id
      for img in fumbbl_session.gallery.get_image_list(0)}
  print(f'done. (count={len(existing_imgs)})')

  print('getting roster data... ', end='')
  sys.stdout.flush()
  roster_data = fumbbl_session.roster.get_data(ROSTER_ID,
      positions_detail=2)
  del roster_data['id']
  del roster_data['ownerRuleset']
  for p in roster_data['positions']:
    del p['title']
  print('done.')

  print('cloning roster... ', end='')
  sys.stdout.flush()
  roster_id = fumbbl_session.roster.append_to_ruleset(
    roster_data, RULESET_ID)
  print(f'done. (id={roster_id})')

  print('getting images again in the gallery home folder... ',
      end='')
  sys.stdout.flush()
  imgs = {img.id
    for img in fumbbl_session.gallery.get_image_list(0)}
  print(f'done. (count={len(imgs)})')

  print('moving new images to the gallery folder... ', end='')
  sys.stdout.flush()
  fumbbl_session.gallery.move_images_to_folder(
      GALLERY_TARGET_FOLDER_ID, *(imgs-existing_imgs))
  print('done.')
