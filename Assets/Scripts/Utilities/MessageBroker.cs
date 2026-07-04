using System;
using System.Collections.Generic;

namespace AstraRift.Utilities
{
    public static class MessageBroker
    {
        private static readonly Dictionary<Type, List<Delegate>> _subscribers = new Dictionary<Type, List<Delegate>>();

        public static void Subscribe<T>(Action<T> callback)
        {
            var type = typeof(T);
            if (!_subscribers.TryGetValue(type, out var list))
            {
                list = new List<Delegate>();
                _subscribers[type] = list;
            }
            list.Add(callback);
        }

        public static void Unsubscribe<T>(Action<T> callback)
        {
            var type = typeof(T);
            if (_subscribers.TryGetValue(type, out var list))
            {
                list.Remove(callback);
            }
        }

        public static void Publish<T>(T message)
        {
            var type = typeof(T);
            if (_subscribers.TryGetValue(type, out var list))
            {
                foreach (var d in list)
                {
                    if (d is Action<T> action)
                    {
                        action(message);
                    }
                }
            }
        }
    }
}
