require 'test_helper'

class TrieTest < ActiveSupport::TestCase
  test "initializes with correct values" do
    trie_node = TrieNode.new
    assert_equal({}, trie_node.next_letters, 'next letters should be an empty hash')
    assert_equal(0, trie_node.occurs, 'each trie node should initialize to 0 occurances')
    assert_equal(-1, trie_node.heap_index, 'each trie node should initially have -1 heap index')
    assert_nil(trie_node.keyword, 'keyword of trie_node set later only on nodes holding the last char of a word')
  end

  test 'add to next letters initializes new node in next letters' do
    trie_node = TrieNode.new
    tmp = trie_node.add('g')
    assert_equal({'g' => tmp }, trie_node.next_letters, 'next letters should have g as a key')
    tmp2 = trie_node.add('i')
    assert_equal({'g' => tmp, 'i' => tmp2 }, trie_node.next_letters, 'next letters should have g and i as keys')
  end

  test 'record word adds keyword to node and increments occurances' do
    trie_node = TrieNode.new
    tmp = trie_node.add('g')
    tmp2 = tmp.add('i')
    tmp3 = tmp2.add('a')
    tmp4 = tmp3.add('n')
    tmp5 = tmp4.add('n')
    tmp6 = tmp5.add('a')
    curr = tmp6.record('gianna')
    assert_equal(tmp6.occurances, 1, 'keyword occurances should increment to 1')
    assert_equal(tmp6.keyword, 'gianna', 'keyword should be stored in instance variable')
  end

  test 'initialize trie tree sets root to new trie node' do
    trie_tree = TrieTree.new
    assert_instance_of(TrieNode, trie_tree.root, 'root of trie tree is a trie node instance')
  end

  test 'add word to trie tree returns instance of last trie node' do
    trie_tree = TrieTree.new
    words = Faker::Hipster.words(10)
    checks = words.inject([]) do |memo, word|
      memo << trie_tree.add(word)
    end.collect { |node| node.keyword if node.occurs == 1 }

    words.each {|word| assert_includes word, checks, 'word should be in tree and occurs once'}
  end
end
