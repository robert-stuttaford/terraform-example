#!/usr/bin/env python
import os
import argparse
import gzip
import Queue
import threading
import tempfile
import hashlib
from boto.s3.connection import S3Connection
from boto.s3.key import Key
from multiprocessing.pool import Pool

gzip_exts = ('.js', '.js.map', '.css')

content_types = {'.css': 'text/css',
                 '.svg': 'image/svg+xml',
                 '.js': 'application/javascript',
                 '.eot': 'application/vnd.ms-fontobject',
                 '.woff': 'application/font-woff',
                 '.ttf': 'application/x-font-ttf'}

cache_max_age_exts = ('.jpeg', '.jpg', '.gif', '.png', '.svg', '.woff', '.ttf', '.eot')
cache_max_age = 60 * 60 * 24 * 30


def gzip_file(source_file, filename):
    tmp_file = tempfile.NamedTemporaryFile(mode="wb", suffix=".gz", delete=False)
    with open(source_file, 'rb') as f_in, gzip.GzipFile(filename, 'wb', 9, tmp_file, 0) as gz_out:
        gz_out.write(f_in.read())
        gz_out.flush()
    return tmp_file.name


def calc_md5(args):
    source_file = args[0]
    s3_key = args[1]

    if source_file.endswith(gzip_exts):
        source_file = gzip_file(source_file, s3_key)

    return [s3_key, hashlib.md5(open(source_file, 'rb').read()).hexdigest()]


def source_files_digest(source_dir, s3_to_upload, prefix):
    files = []
    for s3_key in s3_to_upload:
        source_file = os.path.join(source_dir, s3_key.name.replace(prefix, ''))
        if os.path.isfile(source_file):
            files.append([source_file.encode('ascii', 'replace'), s3_key.name.encode('ascii', 'replace')])
    digests = {}
    for x in Pool().map(calc_md5, files, 1):
        digests[x[0]] = x[1]
    return digests


def upload_file(source_file, s3_key_name, bucket, nr, count):

    with_gzip = source_file.endswith(gzip_exts)

    print('  [{} of {}] {}{}'.format(nr, count, 'GZIP ' if with_gzip else '', s3_key_name))

    s3_key = Key(bucket)
    s3_key.key = s3_key_name
    s3_key.set_metadata('Content-Type', content_types.get(os.path.splitext(source_file)[1]) or 'text/plain')

    if 'public/libs' in source_file or source_file.endswith(cache_max_age_exts):
        s3_key.set_metadata('Cache-Control', 'public, max-age={}'.format(cache_max_age))

    if with_gzip:
        s3_key.set_metadata('Content-Encoding', 'gzip')
        source_file = gzip_file(source_file, s3_key_name)

    s3_key.set_contents_from_filename(source_file)


def upload_worker(queue):
    queue_full = True
    while queue_full:
        try:
            abs_path, key_name, bucket, nr, count = queue.get(False)
            upload_file(abs_path, key_name, bucket, nr, count)
            queue.task_done()
        except Queue.Empty:
            queue_full = False


def dir_to_bucket(source_dir, target_bucket, target_dir):
    print('Sync from {} to bucket: https://s3.amazonaws.com/{}/{}'.format(source_dir, target_bucket, target_dir))

    bucket = S3Connection().get_bucket(target_bucket, validate=False)

    to_upload = {}
    to_delete = []
    unchanged = []

    prefix = '{}/'.format(target_dir)

    bucket_list = bucket.list(prefix)

    md5s = source_files_digest(source_dir, bucket_list, prefix)

    for s3_key in bucket_list:
        s3_key_name = s3_key.name.encode('ascii', 'replace')
        source_file = os.path.join(source_dir, s3_key_name.replace(prefix, '')).encode('ascii', 'replace')
        if os.path.isfile(source_file):
            if md5s[s3_key_name] != s3_key.etag.replace('"', ''):
                to_upload[s3_key_name] = source_file
            else:
                unchanged.append(s3_key_name)
        else:
            if not os.path.isfile(source_dir + s3_key_name.replace(prefix, '')):
                to_delete.append(s3_key)

    # Look for new files in source not in bucket
    for root, sub_folders, files in os.walk(source_dir):
        for file in files:
            abs_path = os.path.join(root, file)
            rel_path = prefix + os.path.relpath(abs_path, source_dir)
            if not (rel_path in to_upload or rel_path in unchanged):
                to_upload[rel_path] = abs_path

    print('{} to upload, {} to delete ({} unchanged).'.format(len(to_upload), len(to_delete), len(unchanged)))

    if to_delete:
        print('** Delete all keys not in source directory:')
        for deleted in bucket.delete_keys(to_delete).deleted:
            print('  {}'.format(deleted.key))
        print('Done.')

    if to_upload:
        print('** Uploading:')

        upload_queue = Queue.Queue()
        nr = 0
        for s3_key, source_file in to_upload.iteritems():
            nr += 1
            upload_queue.put([source_file, s3_key, bucket, nr, len(to_upload)])

        for i in range(5):
            t = threading.Thread(target=upload_worker, args=(upload_queue,))
            t.start()

        upload_queue.join()
        print('Done.')

    print('All done.')

if __name__ == '__main__':

    parser = argparse.ArgumentParser()
    parser.add_argument('source_dir', help='Directory to sync.')
    parser.add_argument('target_bucket', help='S3 bucket to sync to.')
    parser.add_argument('target_dir', help='Directory in S3 bucket to sync to.')
    args = parser.parse_args()

    dir_to_bucket(args.source_dir, args.target_bucket, args.target_dir)
