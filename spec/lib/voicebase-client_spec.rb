require 'spec_helper'

RSpec.describe VoiceBase, vcr: true do
  let(:test_media_file) { 'spec/support/en-us-hello.mp3' }
  let(:test_media_id) { '57196d8a-35af-4da0-8113-bc5f227cd4df' }
  let(:client) { get_vb_client }

  it 'initialize sanely' do
    expect(client).to be_a(VoiceBase::Client)
  end

  it 'fetch media' do
    resp = client.get_media
    expect(resp.http_status).to eq 200
    expect(resp.media).to be_a(Array)
  end

  it 'upload media' do
    resp = client.file_upload media: test_media_file
    expect(resp.http_status).to eq 200
    expect(resp.mediaId).not_to be_empty
  end

  it 'upload mediaUrl' do
    resp = client.upload({ mediaUrl: 'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4' })
    expect(resp.http_status).to eq 200
    expect(resp.mediaId).not_to be_empty
  end

  it 'fetch records with mediaId' do
    resp = client.get_mediaId(test_media_id)
    expect(resp.http_status).to eq 200
    expect(resp.mediaId).to eq test_media_id
    expect(resp.status).to eq 'finished'
  end

  it 'fetch transcripts with mediaId via transcript method' do
    resp = client.transcript(test_media_id, format: 'srt' )
    expect(resp.http_status).to eq 200
    expect(resp.body).to be_a(String)
  end

  it 'raise error for unknown transcript method' do
    expect{ client.transcript(test_media_id, format: '123' ) }.to raise_error('UnknownTranscriptFormat')
  end
end
