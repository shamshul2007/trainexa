-- Migration to add chat_messages table for AI trainer chat history

-- Create chat_messages table
CREATE TABLE IF NOT EXISTS chat_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('user', 'assistant', 'system')),
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_chat_messages_user_id ON chat_messages(user_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_created_at ON chat_messages(created_at);

-- Add RLS policy for chat_messages
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view their own messages
CREATE POLICY chat_messages_select_policy ON chat_messages
  FOR SELECT
  USING (auth.uid() = user_id);

-- Policy: Users can insert their own messages
CREATE POLICY chat_messages_insert_policy ON chat_messages
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own messages
CREATE POLICY chat_messages_update_policy ON chat_messages
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Policy: Users can delete their own messages
CREATE POLICY chat_messages_delete_policy ON chat_messages
  FOR DELETE
  USING (auth.uid() = user_id);
