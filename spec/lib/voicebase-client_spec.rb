require 'spec_helper'

describe VoiceBase, vcr: true do
  let(:test_media_file) { 'spec/support/en-us-hello.mp3' }
  let(:test_media_id) { '9b13b949-6b42-4373-9860-323a4898229c' }

  it "should initialize sanely" do
    client = get_vb_client
    expect(client).to be_a(VoiceBase::Client)
  end

  it "should fetch media" do
    client = get_vb_client
    resp = client.get('/media')
    expect(resp.status).to eq 200
    expect(resp.media).to be_a(Array)
    resp.media.each do |m|
      STDERR.puts "/media has #{m.inspect}"
    end
  end

  it "should upload media" do
    client = get_vb_client
    resp = client.upload media: test_media_file
    expect(resp.status).to eq 200
    expect(resp.mediaId).not_to be_empty
    STDERR.puts "upload saved with mediaId #{resp.mediaId}"
  end

  it "should upload media with premium" do
    client = get_vb_client
    conf = { configuration: { transcripts: { engine: "premium" } } }.to_json
    resp = client.upload media: test_media_file, configuration: conf
    expect(resp.status).to eq 200
    expect(resp.mediaId).not_to be_empty
    STDERR.puts "upload saved with mediaId #{resp.mediaId}"
  end

  if ENV['VB_CALLBACK_URL']
    it "should upload media with callback" do
      client = get_vb_client
      conf = {
        configuration: {
          transcripts: { engine: "premium" },
          publish: {
            callbacks: [{
              method: "POST",
              include: ["transcripts", "topics", "metadata"],
              url: ENV['VB_CALLBACK_URL']
            }]
          }
        }
      }.to_json
      resp = client.upload media: test_media_file, configuration: conf
      expect(resp.status).to eq 200
      expect(resp.mediaId).not_to be_empty
      STDERR.puts "upload saved with mediaId #{resp.mediaId} for callback #{ENV['VB_CALLBACK_URL']}"
    end
  end

  it "should fetch records with mediaId" do
    client = get_vb_client
    resp = client.get "/media/#{test_media_id}"
    expect(resp.status).to eq 200
    expect(resp.media.mediaId).to eq test_media_id
    expect(resp.media.status).not_to be_empty
  end

  it "should fetch transcripts with mediaId" do
    client = get_vb_client
    resp = client.get "/media/#{test_media_id}/transcripts/latest"
    expect(resp.status).to eq 200
    expect(resp.transcripts).not_to be_empty
  end

  it "should fetch transcripts with mediaId via transcripts method" do
    client = get_vb_client
    resp = client.transcripts(test_media_id, format: 'plain' )
    expect(resp.status).to eq 200
    expect(resp.body).to be_a(String)
  end
end
