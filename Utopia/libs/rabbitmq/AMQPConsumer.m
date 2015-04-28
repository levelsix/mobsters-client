//
//  AMQPConsumer.m
//  Objective-C wrapper for librabbitmq-c
//
//  Copyright 2009 Max Wolter. All rights reserved.
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import "AMQPConsumer.h"

# import <amqp.h>
# import <amqp_framing.h>
# import <string.h>
# import <stdlib.h>

# import "AMQPChannel.h"
# import "AMQPQueue.h"
# import "AMQPMessage.h"

@implementation AMQPConsumer

@synthesize internalConsumer = consumer;
@synthesize channel;
@synthesize queue;

- (id)initForQueue:(AMQPQueue*)theQueue onChannel:(AMQPChannel*)theChannel useAcknowledgements:(BOOL)ack isExclusive:(BOOL)exclusive receiveLocalMessages:(BOOL)local
{
  if(self = [super init])
  {
    channel = [theChannel retain];
    queue = [theQueue retain];
    
    amqp_basic_consume_ok_t *response = amqp_basic_consume(channel.connection.internalConnection, channel.internalChannel, queue.internalQueue, AMQP_EMPTY_BYTES, !local, !ack, exclusive, AMQP_EMPTY_TABLE);
    [channel.connection checkLastOperation:@"Failed to start consumer"];
    
    consumer = amqp_bytes_malloc_dup(response->consumer_tag);
  }
  
  return self;
}

- (void)dealloc
{
  amqp_basic_cancel(channel.connection.internalConnection, channel.internalChannel, consumer);
  amqp_bytes_free(consumer);
  [channel release];
  [queue release];
  
  [super dealloc];
}

- (AMQPMessage *) popWithStatus:(amqp_status_enum *)status
{
  amqp_connection_state_t conn = channel.connection.internalConnection;
  amqp_frame_t frame;
  
  amqp_rpc_reply_t ret;
  amqp_envelope_t envelope;
  
  
  struct timeval tv;
  tv.tv_sec = 0;
  tv.tv_usec = 50000;
  
  amqp_maybe_release_buffers(conn);
  ret = amqp_consume_message(conn, &envelope, &tv, 0);
  
  *status = ret.library_error;
  
  if (AMQP_RESPONSE_NORMAL != ret.reply_type) {
    if (AMQP_RESPONSE_LIBRARY_EXCEPTION == ret.reply_type &&
        AMQP_STATUS_UNEXPECTED_STATE == ret.library_error) {
      if (AMQP_STATUS_OK != amqp_simple_wait_frame(conn, &frame)) {
        return nil;
      }
      
      if (AMQP_FRAME_METHOD == frame.frame_type) {
        switch (frame.payload.method.id) {
          case AMQP_BASIC_ACK_METHOD:
            /* if we've turned publisher confirms on, and we've published a message
             * here is a message being confirmed
             */
            fprintf(stderr ,"AMQP ACK\n");
            
            break;
          case AMQP_BASIC_RETURN_METHOD:
            /* if a published message couldn't be routed and the mandatory flag was set
             * this is what would be returned. The message then needs to be read.
             */
          {
            amqp_message_t message;
            ret = amqp_read_message(conn, frame.channel, &message, 0);
            if (AMQP_RESPONSE_NORMAL != ret.reply_type) {
              return nil;
            }
            
            amqp_destroy_message(&message);
          }
            
            break;
            
          case AMQP_CHANNEL_CLOSE_METHOD:
            /* a channel.close method happens when a channel exception occurs, this
             * can happen by publishing to an exchange that doesn't exist for example
             *
             * In this case you would need to open another channel redeclare any queues
             * that were declared auto-delete, and restart any consumers that were attached
             * to the previous channel
             */
            fprintf(stderr ,"CHANNEL CLOSED\n");
            return nil;
            
          case AMQP_CONNECTION_CLOSE_METHOD:
            /* a connection.close method happens when a connection exception occurs,
             * this can happen by trying to use a channel that isn't open for example.
             *
             * In this case the whole connection must be restarted.
             */
            fprintf(stderr ,"CONNECTION CLOSED\n");
            return nil;
            
          default:
            fprintf(stderr ,"An unexpected method was received %d\n", frame.payload.method.id);
            return nil;
        }
      }
    }
    
  } else {
    AMQPMessage *message = [AMQPMessage messageFromEnvelope:&envelope receivedAt:[NSDate date]];
    amqp_destroy_envelope(&envelope);
    return message;
  }
  
  return nil;
}

@end
